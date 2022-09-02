# frozen_string_literal: true

class SendSiatJob < ApplicationJob
  queue_as :default

  def perform(xml, invoice, branch_office)
    daily_code = branch_office.daily_codes.last
    cuis_code = branch_office.cuis_codes.last

    filename = "#{Rails.root}/tmp/mails/#{@invoice.cuf}.xml"
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
      SolicitudServicioRecepcionFactura: {
        codigoAmbiente: 2,
        codigoPuntoVenta: 0,
        codigoSistema: ENV.fetch('system_code', nil),
        codigoSucursal: branch_office.number,
        nit: branch_office.company.nit.to_i,
        codigoDocumentoSector: 1,
        codigoEmision: 1,
        codigoModalidad: 2,
        cufd: daily_code.code,
        cuis: cuis_code.code,
        tipoFacturaDocumento: 1,
        archivo: base64_file,
        fechaEnvio: Date.today,
        hashArchivo: hash
      }
    }
    response = client.call(:recepcion_factura, message: body)
    if response.success?
      invoice.update(send_at: DateTime.now)
      data = response.to_array(:recepcion_factura_response, :respuesta_servicio_facturacion).first 
    else
      render json: 'La solicitud a SIAT obtuvo un error.' 
    end
  end
end
