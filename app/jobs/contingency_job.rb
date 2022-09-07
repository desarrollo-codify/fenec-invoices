# frozen_string_literal: true

class ContingencyJob < ApplicationJob
  queue_as :default

  def perform(contingency)
    current_cuis = contingency.branch_office.cuis_codes.last.code
    current_cufd = contingency.branch_office.daily_codes.last.code
    invoices = contingency.branch_office.invoices
    pending_invoices = invoices.by_cufd(contingency.cufd_code)

    return if pending_invoices.empty?

    event_cufd = pending_invoices.first.cufd_code
    send_package(pending_invoices, contingency, current_cuis, current_cufd)
  end

  def send_contingency(contingency, contingency_cufd, current_cuis, current_cufd)
    client = Savon.client(
      wsdl: ENV.fetch('siat_operations'.to_s, nil),
      headers: {
        'apikey' => ENV.fetch('api_key', nil),
        'SOAPAction' => ''
      },
      namespace: ENV.fetch('siat_namespace', nil),
      convert_request_keys_to: :none
    )
    branch_office = contingency.branch_office
    body = {
      SolicitudEventoSignificativo: {
        codigoAmbiente: 2,
        codigoSistema: ENV.fetch('system_code', nil),
        nit: branch_office.company.nit.to_i,
        cuis: current_cuis,
        cufd: current_cufd,
        codigoSucursal: branch_office.number,
        codigoPuntoVenta: 0,
        codigoMotivoEvento: contingency.significative_event_id,
        descripcion: contingency.significative_event.description,
        fechaHoraInicioEvento: contingency.start_date.strftime('%Y-%m-%dT%H:%M:%S.%L'),
        fechaHoraFinEvento: contingency.end_date.strftime('%Y-%m-%dT%H:%M:%S.%L'),
        cufdEvento: contingency_cufd
      }
    }

    response = client.call(:registro_evento_significativo, message: body)

    if response.success?
      data = response.to_array(:registro_evento_significativo_response, :respuesta_lista_eventos).first
      code = data[:codigo_recepcion_evento_significativo]
      contingency.update(reception_code: data[:codigo_recepcion_evento_significativo])
    else
      data = 'Communication error'
    end
  end

  def send_package(invoices, contingency, current_cuis, current_cufd)
    invoices.each do |invoice|
      xml = generate_xml(invoice)
      filename = "#{Rails.root}/tmp/invoices/#{invoice.cuf}.xml"
      File.write(filename, xml)
    end
    # TODO: comprimir todo?
    filename = "#{Rails.root}/tmp/invoices/"
    zipped_filename = "#{filename}prueba.gz"

    # # Add a path and its content to a gzipped tar archive
    # writer = GZippedTar::Writer.new
    # invoices.each do |invoice|
    #   xml = generate_xml(invoice)
    #   writer.add "facturas.xml", xml
    # end
    # file = writer.output
    # debugger
    # base = Base64.strict_encode64(file)
    # debugger

    # # Write that archive to disk:
    # File.write zipped_filename, writer.output
    # debugger

    # tar = create_tarball(filename)
    # cdtargz(filename, zipped_filename, src)

    # Zlib::GzipWriter.open(zipped_filename) do |gz|
    #   gz.write IO.binread(filename)
    # end

    base64_file = Base64.strict_encode64(File.binread(zipped_filename))
    hash = Digest::SHA2.hexdigest(base64_file)

    client = Savon.client(
      wsdl: ENV.fetch('send_siat'.to_s, nil),
      headers: {
        'apikey' => ENV.fetch('api_key', nil),
        'SOAPAction' => ''
      },
      namespace: ENV.fetch('siat_namespace', nil),
      convert_request_keys_to: :none
    )

    branch_office = contingency.branch_office
    body = {
      SolicitudServicioRecepcionPaquete: {
        codigoAmbiente: 2,
        codigoPuntoVenta: 0,
        codigoSistema: ENV.fetch('system_code', nil),
        codigoSucursal: branch_office.number,
        nit: branch_office.company.nit.to_i,
        codigoDocumentoSector: 1,
        codigoEmision: 2,
        codigoModalidad: 2,
        cufd: current_cufd,
        cuis: current_cuis,
        tipoFacturaDocumento: 1,
        archivo: base64_file,
        fechaEnvio: Date.today,
        hashArchivo: hash,
        cantidadFacturas: invoices.count,
        codigoEvento: contingency.significative_event_id
      }
    }
    response = client.call(:recepcion_paquete_factura, message: body)
    if response.success?
      data = response.to_array(:recepcion_paquete_factura_response, :respuesta_servicio_facturacion)
    else
      render json: 'La solicitud a SIAT obtuvo un error.'
    end
  end

  def reception_validation(contingency)
    branch_office = contingency.branch_office
    cuis_code = contingency.branch_office.cuis_codes.last
    cufd_code = contingency.branch_office.daily_codes.last
    client = Savon.client(
      wsdl: ENV.fetch('siat_invoices'.to_s, nil),
      headers: {
        'apikey' => ENV.fetch('api_key', nil),
        'SOAPAction' => ''
      },
      namespace: ENV.fetch('siat_namespace', nil),
      convert_request_keys_to: :none
    )

    body = {
      SolicitudServicioValidacionRecepcionPaquete: {
        codigoAmbiente: 2,
        codigoSistema: ENV.fetch('system_code', nil),
        codigoSucursal: branch_office.number,
        nit: branch_office.company.nit.to_i,
        codigoDocumentoSector: 1,
        codigoEmision: 2,
        codigoModalidad: 2,
        cufd: cufd_code.code,
        cuis: cuis_code.code,
        tipoFacturaDocumento: 1,
        codigoRecepcion: contingency.reception_code
      }
    }
    response = client.call(:validacion_recepcion_paquete_factura, message: body)
    if response.success?
      data = response.to_array(:validacion_recepcion_paquete_factura_response, :respuesta_servicio_facturacion, :mensajes_list)
      data = data[:codigoEstado]
    else
      data = { return: 'communication error' }
    end
  end

  private

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
          xml.cafc @invoice.cafc if invoice.cafc

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

    builder.to_xml
  end

  BLOCKSIZE_TO_READ = 1024 * 1000

  def create_tarball(path)
    tar_filename = "#{Pathname.new(path).realpath.to_path}.tar"

    File.open(tar_filename, 'wb') do |tarfile|
      Gem::Package::TarWriter.new(tarfile) do |tar|
        Dir[File.join(path, '**/*')].each do |file|
          mode = File.stat(file).mode
          relative_file = file.sub(%r{^#{Regexp.escape(path)}/?}, '')

          if File.directory?(file)
            tar.mkdir(relative_file, mode)
          else

            tar.add_file(relative_file, mode) do |tf|
              File.open(file, 'rb') do |f|
                while buffer = f.read(BLOCKSIZE_TO_READ)
                  tf.write buffer
                end
              end
            end

          end
        end
      end
    end

    tar_filename
  end

  def cdtargz(cdpath, targzfile, *src)
    path = Pathname.new(cdpath)
    raise "path #{cdpath} should be an absolute path" unless path.absolute?
    raise "path #{cdpath} should be a directory" unless File.directory? cdpath
    raise "Destination tar.gz file #{targzfile} already exists" if File.exist? targzfile
    raise 'no file or directory to tar' if !src || src.length.zero?

    src.each { |p| p.sub!(/^/, "#{cdpath}/") }
    File.open targzfile, 'wb' do |otargzfile|
      Zlib::GzipWriter.wrap otargzfile do |gz|
        Gem::Package::TarWriter.new gz do |tar|
          Find.find(*src) do |f|
            relative_path = f.sub "#{cdpath}/", ''
            mode = File.stat(f).mode
            size = File.stat(f).size
            if File.directory? f
              tar.mkdir relative_path, mode
            else
              tar.add_file_simple relative_path, mode, size do |tio|
                File.open f, 'rb' do |rio|
                  while buffer = rio.read(BLOCKSIZE_TO_READ)
                    tio.write buffer
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
