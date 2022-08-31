# frozen_string_literal: true

class ApplicationController < ActionController::API
  def VerifyCommunication
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
        data = {return: 'communication error'}
      end
      return data
    end
end
