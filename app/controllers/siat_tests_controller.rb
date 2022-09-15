# frozen_string_literal: true

class SiatTestsController < ApplicationController
  before_action :set_company, only: %i[sync_codes cufd_codes]

  def sync_codes
    client = siat_client('products_wsdl')

    pos = params[:point_of_sale]
    body = {
      SolicitudSincronizacion: {
        codigoAmbiente: 2,
        codigoSistema: @company.company_setting.system_code,
        nit: @company.nit.to_i,
        cuis: @cuis_code.code,
        codigoSucursal: 0,
        codigoPuntoVenta: pos
      }
    }

    (1..50).each do |i|
      response = client.call(params[:siat_key].to_sym, message: body)
      if response.success?
        puts response.success?
        puts "Punto #{pos} - #{i}..."
      end
    end
    :ok
  end

  def cufd_codes
    (1..100).each do |i|
      pos = params[:point_of_sale]
      client = siat_client('cuis_wsdl')
      body = {
        SolicitudCufd: {
          codigoAmbiente: 2,
          codigoPuntoVenta: pos,
          codigoSistema: @company.company_setting.system_code,
          nit: @company.nit.to_i,
          codigoModalidad: 2,
          cuis: @cuis_code.code,
          codigoSucursal: params[:branch_office]
        }
      }

      response = client.call(:cufd, message: body)
      next unless response.success?

      data = response.to_array(:cufd_response, :respuesta_cufd).first
      puts data
      puts "Punto #{pos} - #{i}..."
    end
  end

  def generate_invoices
    (1..123).each do |i|
      # TODO: implement validate!
      @branch_office = BranchOffice.find(params[:branch_office_id])

      @invoice = @branch_office.invoices.build(invoice_params)
      @company = @branch_office.company

      @invoice.company_name = @branch_office.company.name
      @invoice.company_nit = @branch_office.company.nit
      @invoice.municipality = @branch_office.city
      @invoice.phone = @branch_office.phone

      daily_code = @branch_office.daily_codes.current
      @invoice.cufd_code = daily_code.code

      client = @company.clients.find_by(code: invoice_params[:client_code])
      @invoice.business_name = client.name
      @invoice.business_nit = client.nit
      @invoice.complement = client.complement
      @invoice.document_type = client.document_type_id

      @invoice.date = DateTime.now
      @invoice.control_code = daily_code.control_code
      @invoice.branch_office_number = @branch_office.number
      @invoice.address = @branch_office.address
      activity_code = invoice_params[:invoice_details_attributes].first[:economic_activity_code]
      @economic_activity = @company.economic_activities.find_by(code: activity_code)
      contingency = @branch_office.contingencies.pending.last
      @invoice.cafc = if contingency && params[:is_manual].present?
                        contingency.significative_event_id >= 5 ? @economic_activity.contingency_codes.first.code : nil
                      end
      @invoice.document_sector_code = 1
      @invoice.total = @invoice.subtotal - @invoice.discount - @invoice.gift_card - @invoice.advance
      @invoice.cash_paid = @invoice.total # TODO: implement different payments
      @invoice.invoice_status_id = 1
      @economic_activity = @company.economic_activities.find_by(code: activity_code)
      @invoice.legend = @economic_activity.random_legend.description

      @invoice.invoice_details.each do |detail|
        detail.total = detail.subtotal
        detail.product = @company.products.find_by(primary_code: detail.product_code)
        detail.sin_code = detail.product.sin_code
      end
      render json: @invoice.errors, status: :unprocessable_entity unless @invoice.valid?

      if @invoice.save
        process_pending_data(@invoice)
        invoice_job(@invoice, invoice_params[:client_code])
      end

      puts '****************'
      puts "Factura #{i}..."
    end
  end

  def cancel_invoices
    # Solo dejar en la BD las facturas validadas que se vayan a anular
    invoices = Invoice.where(cancellation_reason_id: nil)
    invoices.each_with_index do |invoice, i|
      if invoice.cancellation_date?
        return render json: "La factura ya fue anulada el #{invoice.cancellation_date}",
                      status: :unprocessable_entity
      end
      reason = params[:reason]

      branch_office = invoice.branch_office
      daily_code = branch_office.daily_codes.current
      cuis_code = branch_office.cuis_codes.current

      client = Savon.client(
        wsdl: ENV.fetch('siat_pilot_invoices', nil),
        headers: {
          'apikey' => branch_office.company.company_setting.api_key,
          'SOAPAction' => ''
        },
        namespace: ENV.fetch('siat_namespace', nil),
        convert_request_keys_to: :none
      )

      body = {
        SolicitudServicioAnulacionFactura: {
          codigoAmbiente: 2,
          codigoPuntoVenta: invoice.point_of_sale,
          codigoSistema: branch_office.company.company_setting.system_code,
          codigoSucursal: branch_office.number,
          nit: branch_office.company.nit.to_i,
          codigoDocumentoSector: 1,
          codigoEmision: 1,
          codigoModalidad: 2,
          cufd: daily_code.code,
          cuis: cuis_code.code,
          tipoFacturaDocumento: 1,
          codigoMotivo: reason,
          cuf: invoice.cuf
        }
      }
      response = client.call(:anulacion_factura, message: body)
      data = response.to_array(:anulacion_factura_response, :respuesta_servicio_facturacion).first
      invoice.update(cancellation_date: DateTime.now, cancellation_reason_id: reason, invoice_status_id: 2) if response.success?

      puts data
      puts '********'
      puts "Factura #{i}..."
    end

    head :ok
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
    @cuis_code = @company.branch_offices.find_by(number: params[:branch_office_id]).cuis_codes.current
  end

  def siat_client(wsdl_name)
    Savon.client(
      wsdl: ENV.fetch(wsdl_name.to_s, nil),
      headers: {
        'apikey' => @company.company_setting.api_key,
        'SOAPAction' => ''
      },
      namespace: ENV.fetch('siat_namespace', nil),
      convert_request_keys_to: :none
    )
  end

  def invoice_job(invoice, client_code)
    @invoice = invoice
    @company = invoice.branch_office.company
    @client = @company.clients.find_by(code: client_code)
    @branch_office = invoice.branch_office
    generate_xml(@invoice)
    @invoice.update(sent_at: DateTime.now)

    send_to_siat(@invoice)
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
        cuis: invoice.branch_office.cuis_codes.current.code,
        tipoFacturaDocumento: 1,
        archivo: base64_file,
        fechaEnvio: DateTime.now.strftime('%Y-%m-%dT%H:%M:%S.%L'),
        hashArchivo: file_hash(base64_file)
      }
    }
    response = client.call(:recepcion_factura, message: body)
    data = response.to_array(:recepcion_factura_response, :respuesta_servicio_facturacion).first
    puts data
  end

  def file_hash(file)
    Digest::SHA2.hexdigest(file)
  end

  def generate_gzip_file(invoice)
    filename = "#{Rails.root}/public/tmp/mails/#{invoice.cuf}.xml"
    zipped_filename = "#{filename}.gz"

    Zlib::GzipWriter.open(zipped_filename) do |gz|
      gz.write File.binread(filename)
    end
    Base64.strict_encode64(File.binread(zipped_filename))
  end

  def process_pending_data(invoice)
    invoice.number = invoice_number
    invoice.cuf = cuf(invoice.date, invoice.number, invoice.control_code)
    # TODO: implement paper size: 1 roll, 2 half office or half letter
    invoice.qr_content = qr_content(invoice.company_nit, invoice.cuf, invoice.number, 1)
    invoice.save
  end

  def invoice_number
    cuis_code = @branch_office.cuis_codes.current
    current_number = cuis_code.current_number
    cuis_code.increment!
    current_number
  end

  def cuf(invoice_date, invoice_number, control_code)
    nit = @branch_office.company.nit.rjust(13, '0')
    date = invoice_date.strftime('%Y%m%d%H%M%S%L')
    branch_office = @branch_office.number.to_s.rjust(4, '0')
    modality = '2' # TODO: save modality in company or branch office
    generation_type = '1' # TODO: add generation types for: online, offline and massive
    invoice_type = '1' # TODO: add invoice types table
    sector_document_type = '1'.rjust(2, '0') # TODO: add sector types table
    number = invoice_number.to_s.rjust(10, '0')
    point_of_sale = @invoice.point_of_sale.to_s.rjust(4, '0') # TODO: implement point of sales for each branch office

    long_code = nit + date + branch_office + modality + generation_type + invoice_type + sector_document_type + number +
                point_of_sale
    mod_11_value = module_eleven(long_code, 9)
    hex_code = hex_base(mod_11_value.to_i)
    (hex_code + control_code).upcase
  end

  def invoice_params
    params.require(:invoice).permit(:business_name, :document_type, :business_nit, :complement, :client_code, :payment_method,
                                    :card_number, :subtotal, :gift_card_total, :discount, :exception_code, :cafc,
                                    :currency_code, :exchange_rate, :currency_total, :user, :document_sector_code,
                                    :cancellation_reason_id, :point_of_sale,
                                    invoice_details_attributes: %i[product_code description quantity measurement_id
                                                                   unit_price discount subtotal serial_number imei_code
                                                                   economic_activity_code])
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
end
