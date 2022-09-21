# frozen_string_literal: true

class SendInvoiceJob < ApplicationJob
  queue_as :default
  require 'generate_cufd'
  require 'siat_available'

  def perform(invoice, client_code)
    @invoice = invoice
    @company = invoice.branch_office.company
    @client = @company.clients.find_by(code: client_code)
    @branch_office = invoice.branch_office
    
    if SiatAvailable.available(@invoice, true) == true
      @invoice.update(sent_at: DateTime.now)
      if @invoice.branch_office.point_of_sales.find_by(code: @invoice.point_of_sale).contingencies.pending.any?
        close_contingencies(@branch_office, @invoice)
        process_invoice(@branch_office, @invoice)
      end
      generate_xml(@invoice)
      send_to_siat(@invoice)
    else
      # rubocop:disable all
      @invoice.update(graphic_representation_text: 'Este documento es la Representación Gráfica de un Documento Fiscal Digital emitido fuera de línea, verifique su envío con su proveedor o en la página web www.impuestos.gob.bo.')
      # rubocop:enable all
      unless @invoice.branch_office.point_of_sales.find_by(code: @invoice.point_of_sale).contingencies.pending.any?
        create_contingency(@invoice, 2)
      end
      generate_xml(@invoice)
    end

    begin
      InvoiceMailer.with(client: @client, invoice: @invoice, xml: @xml,
                         sender: @company.company_setting).send_invoice.deliver_now
    rescue StandardError => e
      p e.message
    end
  end

  def send_to_siat(invoice)
    client = Savon.client(
      wsdl: ENV.fetch('siat_pilot_invoices', nil),
      headers: {
        'apikey' => invoice.branch_office.company.company_setting.api_key,
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
        codigoSistema: invoice.branch_office.company.company_setting.system_code,
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
    p response.to_array(:recepcion_factura_response, :respuesta_servicio_facturacion).first
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
            xml.subTotal detail.total

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

  def create_contingency(invoice, significative_event)
    @invoice.branch_office.point_of_sales.find_by(code: invoice.point_of_sale)
            .contingencies.create(start_date: invoice.date,
                                  cufd_code: invoice.cufd_code,
                                  significative_event_id: significative_event,
                                  point_of_sale_id: invoice.point_of_sale)
  end

  def close_contingencies(branch_office, invoice)
    GenerateCufd.generate(branch_office, invoice)
    @contingency = invoice.branch_office.point_of_sales.find_by(code: invoice.point_of_sale).contingencies.pending.last
    @contingency.close!
    #ContingencyJob.perform_now(@contingency)
    SendCancelInvoicesJob.perform_now
  end

  def process_invoice(branch_office, invoice)
    daily_code = branch_office.daily_codes.where(point_of_sale: invoice.point_of_sale).current
    invoice.update(cufd_code: daily_code.code, control_code: daily_code.control_code)
    cuf = cuf(invoice.date, invoice.number, invoice.control_code, invoice.point_of_sale, branch_office)
    invoice.update(cuf: cuf)
    invoice.qr_content = qr_content(invoice.company_nit, invoice.cuf, invoice.number, 1)
    invoice.save
  end

  def module_eleven(code, limit)
    sum = 0
    multiplier = 2
    code.reverse.each_char.with_index do |character, _i|
      sum += multiplier * character.to_i
      multiplier += 1
      multiplier = 2 if multiplier > limit
    end
    digit = sum % 11
    last_char = digit == 10 ? '1' : digit.to_s
    code + last_char
  end

  def hex_base(value)
    value.to_s(16)
  end

  def qr_content(nit, cuf, number, page_size)
    base_url = ENV.fetch('siat_url', nil)
    params = { nit: nit, cuf: cuf, numero: number, t: page_size }
    "#{base_url}?#{params.to_param}"
  end

  def cuf(invoice_date, current_number, control_code, point_of_sale, branch_office)
    nit = branch_office.company.nit.rjust(13, '0')
    date = invoice_date.strftime('%Y%m%d%H%M%S%L')
    branch_office = branch_office.number.to_s.rjust(4, '0')
    modality = '2' # TODO: save modality in company or branch office
    generation_type = '1' # TODO: add generation types for: online, offline and massive
    invoice_type = '1' # TODO: add invoice types table
    sector_document_type = '1'.rjust(2, '0') # TODO: add sector types table
    number = current_number.to_s.rjust(10, '0')
    point_of_sale = point_of_sale.to_s.rjust(4, '0')

    long_code = nit + date + branch_office + modality + generation_type + invoice_type + sector_document_type + number +
                point_of_sale
    mod_11_value = module_eleven(long_code, 9)
    hex_code = hex_base(mod_11_value.to_i)
    (hex_code + control_code).upcase
  end
end
