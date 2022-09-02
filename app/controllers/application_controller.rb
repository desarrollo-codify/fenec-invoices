# frozen_string_literal: true

class ApplicationController < ActionController::API
  
  def siat_available
    client =Savon.client(
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
      data = {return: 'Communication error'}
    end
    data == '926'
  end

  

  def ReceptionValidation(branch_office)
    cuis_code = branch_office.cuis_codes.last
    cufd_code = branch_office.daily_codes.last
    contingency = branch_office.contingencies.last
    client =Savon.client(
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
        codigoDocumentoSector: 1
        codigoEmision: 2
        codigoModalidad: 2
        cufd: cufd_code.code,
        cuis: cuis_code.code,
        tipoFacturaDocumento: 1
        codigoRecepcion: 
      }
    }
    response = client.call(:validacion_recepcion_paquete_factura, message: body)
    if response.success?
      data = response.to_array(:validacion_recepcion_paquete_factura_response, :respuesta_servicio_facturacion , :mensajes_list)
      data = data[:return]
    else
      data = {return: 'communication error'}
    end
    return data
  end
end
