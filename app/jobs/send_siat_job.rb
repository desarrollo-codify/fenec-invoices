class SendSiatJob < ApplicationJob
  queue_as :default

  def perform(xml, branch_office)
    @branch_office = branch_office
    xml = File.write("#{Rails.root}/tmp/factura.xml", xml)
    hash = Digest::SHA256.hexdigest(@xml)

    client = siat_client('send_siat')
        body = {
          SolicitudServicioRecepcionFactura: {
            codigoAmbiente: 2,
            codigoSistema: ENV.fetch('system_code', nil),
            codigoSucursal: @branch_office.number,
            nit: @branch_office.company.nit.to_i,
            codigoDocumentoSector: 1,
            codigoEmision: 1,
            codigoModalidad: 2,
            cufd: @branch_office.daily_code.code,
            cuis: @branch_office.cuis_code.code,
            tipoFacturaDocumento: 1,
            archivo: xml,
            fechaEnvio: Date.today,
            hashArchivo: hash
          }
        }

        response = client.call(:recepcion_factura, message: body)
        if response.success?
          data = response.to_array(:recepcion_factura_response, :respuesta_servicio_facturacion).first

          render json: data
        else
          render json: 'La solicitud a SIAT obtuvo un error.', status: :internal_server_error
        end

    def siat_client(wsdl_name)
      Savon.client(
        wsdl: ENV.fetch(wsdl_name.to_s, nil),
        headers: {
          'apikey' => ENV.fetch('api_key', nil),
          'SOAPAction' => ''
        },
        namespace: ENV.fetch('siat_namespace', nil),
        convert_request_keys_to: :none
      )
    end
  end
end
