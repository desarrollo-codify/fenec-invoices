class ContingencyJob < ApplicationJob
  queue_as :default

  def perform(contingency)
    current_cuis = contingency.branch_offices.cuis_codes.last.code
    current_cufd = contingency.branch_offices.daily_codes.last.code
    pending_invoices = contingency.branch_office.invoices.between_dates(contigency.start_date, contigency.end_date)

    return if pending_invoices.empty?

    event_cufd = pending_invoices.first.cufd_code
    send_contingency(contingency, event_cufd, current_cuis, current_cufd)
    send_package(pending_invoices, contingency, current_cuis, current_cufd)
    
  end

  private
  
  def send_contingency(contingency, contingency_cufd, current_cuis, current_cufd)
    client =Savon.client(
      wsdl: ENV.fetch('siat_operations'.to_s, nil),
      headers: {
        'apikey' => ENV.fetch('api_key', nil),
        'SOAPAction' => ''
      },
      namespace: ENV.fetch('siat_namespace', nil),
      convert_request_keys_to: :none
    )

    branch_office = contigency.branch_office
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
        fechaHoraInicioEvento: contingency.start_date,
        fechaHoraFinEvento: contingency.end_date,
        cufdEvento: contingency_cufd,
      }
    }

    response = client.call(:registro_evento_significativo, message: body)
    if response.success?
      data = response.to_array(:registro_evento_significativo_response, :respuesta_lista_eventos, :mensajes_list)
      contingency.update(reception_code: data[:codigoRecepcion])
    else
      data = 'Communication error'
    end
  end

  def send_package(invoices, contingency, current_cuis, current_cufd)
    invoices.each do |invoice|
      xml = InvoiceXml.generate(invoice)
      filename = "#{Rails.root}/tmp/invoices/#{@invoice.cuf}.xml"
      File.write(filename, xml)  
    end

    # TODO: comprimir todo?
    filename = "#{Rails.root}/tmp/invoices"
    zipped_filename = "#{filename}.gz"

    Zlib::GzipWriter.open(zipped_filename) do |gz|
      gz.write IO.binread(filename)
      
    base64_file = Base64.strict_encode64(IO.binread(zipped_filename))
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
        hashArchivo: hash
        cantidadFacturas: invoices.count
        codigoEvento: contingency.significative_event_id
      }
    }
    response = client.call(:recepcion_paquete_factura, message: body)
    if response.success?
      data = response.to_array(:recepcion_paquete_factura_response, :respuesta_servicio_facturacion, :mensajes_list)
    else
      render json: 'La solicitud a SIAT obtuvo un error.' 
    end  
  end
end
