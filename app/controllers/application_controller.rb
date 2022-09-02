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

  def ReceptionValidation(contingency)
    cuis_code = contingency.branch_offices.cuis_codes.last
    cufd_code = contingency.branch_offices.daily_codes.last
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
        codigoRecepcion: contingency.reception_code
      }
    }
    response = client.call(:validacion_recepcion_paquete_factura, message: body)
    if response.success?
      data = response.to_array(:validacion_recepcion_paquete_factura_response, :respuesta_servicio_facturacion , :mensajes_list)
      data = data[:codigoEstado]
    else
      data = {return: 'communication error'}
    end
    if data == '908'
      data = 'valid'
    else 
      if data == '904'
        data = 'observed'
      else
        data = 'pending' if data == '901'
    end
  end
end
