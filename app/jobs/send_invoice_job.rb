# frozen_string_literal: true

class SendInvoiceJob < ApplicationJob
  queue_as :default
  require 'generate_cufd'

  def perform(invoice, client_code)
    @invoice = invoice
    @company = invoice.branch_office.company
    @client = @company.clients.find_by(code: client_code)
    @branch_office = invoice.branch_office
    generate_xml(@invoice)
    # begin
    #   InvoiceMailer.with(client: @client, invoice: @invoice, xml: @xml, sender: @company.mail_setting).send_invoice.deliver_now
    # rescue StandardError => e
    #   p e.message
    # end
    if siat_available(@invoice) == true
      @invoice.update(sent_at: DateTime.now)
      send_to_siat(@invoice)
      if @invoice.branch_office.point_of_sales.find_by(code: @invoice.point_of_sale).contingencies.pending.any?
        close_contingencies(@branch_office,
                            @invoice)
      end
    else
      unless @invoice.branch_office.point_of_sales.find_by(code: @invoice.point_of_sale).contingencies.pending.any?
        create_contingency(@invoice,
                           2)
      end
    end
  end

  def send_to_siat(invoice)
    client = Savon.client(
      wsdl: ENV.fetch('siat_pilot_invoices', nil),
      headers: {
        'apikey' => ENV.fetch('api_key', nil),
        'SOAPAction' => ''
      },
      namespace: ENV.fetch('siat_namespace', nil),
      convert_request_keys_to: :none
    )

    filename = "#{Rails.root}/public/tmp/mails/#{invoice.cuf}.xml"
    zipped_filename = "#{filename}.gz"

    Zlib::GzipWriter.open(zipped_filename) do |gz|
      gz.write File.binread(filename)
    end

    base64_file = generate_gzip_file(invoice)
    body = {
      SolicitudServicioRecepcionFactura: {
        codigoAmbiente: 2,
        codigoPuntoVenta: invoice.point_of_sale,
        codigoSistema: ENV.fetch('system_code', nil),
        codigoSucursal: invoice.branch_office.number,
        nit: invoice.branch_office.company.nit.to_i,
        codigoDocumentoSector: 1,
        codigoEmision: 1,
        codigoModalidad: 2,
        cufd: invoice.cufd_code,
        cuis: invoice.branch_office.cuis_codes.where(point_of_sale: invoice.point_of_sale).current.code,
        tipoFacturaDocumento: 1,
        archivo: base64_file,
        fechaEnvio: DateTime.now.strftime('%Y-%m-%dT%H:%M:%S.%L'),
        hashArchivo: file_hash(base64_file)
      }
    }
    response = client.call(:recepcion_factura, message: body)

    data = response.to_array(:recepcion_factura_response, :respuesta_servicio_facturacion).first
    p data
    # TODO: process all possible scenarios
  end

  def generate_gzip_file(invoice)
    filename = "#{Rails.root}/public/tmp/mails/#{invoice.cuf}.xml"
    zipped_filename = "#{filename}.gz"

    Zlib::GzipWriter.open(zipped_filename) do |gz|
      gz.write File.binread(filename)
    end
    Base64.strict_encode64(File.binread(zipped_filename))
  end

  def file_hash(file)
    Digest::SHA2.hexdigest(file)
  end

  def generate_xml(invoice)
    header = Nokogiri::XML('<?xml version = "1.0" encoding = "UTF-8" standalone ="yes"?>')
    builder = Nokogiri::XML::Builder.with(header) do |xml|
      xml.facturaComputarizadaCompraVenta('xsi:noNamespaceSchemaLocation' => '/compraVenta/facturaComputarizadaCompraVenta.xsd',
                                          'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance') do
        xml.cabecera do
          xml.nitEmisor invoice.company_nit
          xml.razonSocialEmisor invoice.company_name
          xml.municipio invoice.municipality
          xml.telefono invoice.phone
          xml.numeroFactura invoice.number
          xml.cuf invoice.cuf
          xml.cufd invoice.cufd_code
          xml.codigoSucursal invoice.branch_office_number
          xml.direccion invoice.address

          # point of sale
          xml.codigoPuntoVenta('xsi:nil' => true) unless invoice.point_of_sale
          xml.codigoPuntoVenta invoice.point_of_sale if invoice.point_of_sale

          xml.fechaEmision invoice.date.strftime('%FT%T.%L') # format: "2022-08-21T19:26:40.905"
          xml.nombreRazonSocial invoice.business_name
          xml.codigoTipoDocumentoIdentidad invoice.document_type
          xml.numeroDocumento invoice.business_nit

          # complement
          xml.complemento('xsi:nil' => true) unless invoice.complement
          xml.complemento invoice.complement if invoice.complement

          xml.codigoCliente invoice.client_code
          xml.codigoMetodoPago invoice.payment_method

          # card number
          xml.numeroTarjeta('xsi:nil' => true) unless invoice.card_number
          xml.numeroTarjeta @invoice.card_number if invoice.card_number

          xml.montoTotal invoice.total
          xml.montoTotalSujetoIva invoice.total # TODO: check for not IVA
          xml.codigoMoneda invoice.currency_code
          xml.tipoCambio invoice.exchange_rate
          xml.montoTotalMoneda invoice.currency_total
          xml.montoGiftCard invoice.gift_card_total
          xml.descuentoAdicional invoice.discount

          # exception code
          xml.codigoExcepcion('xsi:nil' => true) unless invoice.exception_code
          xml.codigoExcepcion invoice.exception_code if invoice.exception_code

          # cafc
          xml.cafc('xsi:nil' => true) unless invoice.cafc
          xml.cafc invoice.cafc if invoice.cafc

          xml.leyenda invoice.legend
          xml.usuario invoice.user

          # document sector
          xml.codigoDocumentoSector('xsi:nil' => true) unless invoice.document_sector_code
          xml.codigoDocumentoSector invoice.document_sector_code if invoice.document_sector_code
        end
        invoice.invoice_details.each do |detail|
          xml.detalle do
            xml.actividadEconomica detail.economic_activity_code # invoice.invoice_details.activity_type
            xml.codigoProductoSin detail.sin_code
            xml.codigoProducto detail.product_code
            xml.descripcion detail.description
            xml.cantidad detail.quantity
            xml.unidadMedida detail.measurement_id
            xml.precioUnitario detail.unit_price
            xml.montoDescuento detail.discount
            xml.subTotal detail.subtotal

            # card number
            xml.numeroSerie('xsi:nil' => true) unless detail.serial_number
            xml.numeroSerie detail.serial_number if detail.serial_number

            # imei number
            xml.numeroImei('xsi:nil' => true) unless detail.imei_code
            xml.numeroImei detail.imei_code if detail.imei_code
          end
        end
      end
    end

    filename = "#{Rails.root}/public/tmp/mails/#{invoice.cuf}.xml"
    File.write(filename, builder.to_xml)
  end

  def siat_available(invoice)
    client = Savon.client(
      wsdl: ENV.fetch('siat_invoices'.to_s, nil),
      headers: {
        'apikey' => ENV.fetch('api_key', nil),
        'SOAPAction' => ''
      },
      namespace: ENV.fetch('siat_namespace', nil),
      convert_request_keys_to: :none
    )

    response = client.call(:verificar_comunicacion)
    if response.success?
      data = response.to_array(:verificar_comunicacion_response).first
      data = data[:return]
    else
      data = { return: 'Communication error' }
    end
    data == '926'
  rescue StandardError => e
    create_contingency(invoice, 1) if e.message.include?('TCP connection') && invoice.branch_office.contingencies.pending.none?
  end

  def create_contingency(invoice, significative_event)
    @invoice.branch_office.point_of_sales.find_by(code: invoice.point_of_sale).contingencies.create(start_date: invoice.date, cufd_code: invoice.cufd_code,
                                                                                                    significative_event_id: significative_event, point_of_sale_id: invoice.point_of_sale)
  end

  def close_contingencies(branch_office, invoice)
    GenerateCufd.generate(branch_office, invoice)
    @contingency = invoice.branch_office.point_of_sales.find_by(code: invoice.point_of_sale).contingencies.pending.last
    @contingency.close!
    ContingencyJob.perform_now(@contingency)
  end
end
