class SendSiatJob < ApplicationJob
  queue_as :default
  require 'savon'
  require 'zip'

  def perform(xml, branch_office)
    daily_code = branch_office.daily_codes.last
    cuis_code = branch_office.cuis_codes.last

    xml_file = File.write("#{Rails.root}/tmp/gzip.xml", xml)
    gzip = ActiveSupport::Gzip.compress(xml)

    orig = "#{Rails.root}/tmp/gzip.xml"
    gzip3 = Zlib::GzipWriter.open("#{Rails.root}/tmp/gzip.gz") do |gz|
              gz.mtime = File.mtime(orig)
              gz.orig_name = orig
              gz.write IO.binread(orig)
            end

    zipfile_name = "#{Rails.root}/tmp/zipfile.zip"
    gzip2 = ActiveSupport::Gzip.decompress(gzip)
    hash = Digest::SHA256.hexdigest(gzip3)

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
        archivo: gzip3,
        fechaEnvio: Date.today,
        hashArchivo: hash
      }
    }
    debugger
    response = client.call(:recepcion_factura, message: body)
    if response.success?
      data = response.to_array(:recepcion_factura_response, :respuesta_servicio_facturacion).first 
    else
      data = 'La solicitud a SIAT obtuvo un error.'
      # TODO: Handle errors
    end
  end
end
