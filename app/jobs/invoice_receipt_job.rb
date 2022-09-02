class InvoiceReceiptJob < ApplicationJob
  queue_as :default

  def perform(branch_office)
    daily_code = branch_office.daily_codes.last
    cuis_code = branch_office.cuis_codes.last
    contingency = branch_office.contingencies.last

    invoices = branch_office.invoices.find_by(send_at: nil)
    x = 0
    while invoices.count > 0 
      xml = generate_xml(invoices[x])
      filename = "#{Rails.root}/tmp/invoices/#{@invoice.cuf}.xml"
      File.write(filename, xml)
      x += 1

    filename = "#{Rails.root}/tmp/invoices"
    zipped_filename = "#{filename}.gz"

    Zlib::GzipWriter.open(zipped_filename) do |gz|
      gz.write IO.binread(filename)
    end
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
        cufd: daily_code.code,
        cuis: cuis_code.code,
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
