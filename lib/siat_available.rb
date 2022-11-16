# frozen_string_literal: true

class SiatAvailable
  def self.available(api_key)
    client = Savon.client(
      wsdl: ENV.fetch('siat_sales_invoice_service_wsdl'.to_s, nil),
      headers: {
        'apikey' => api_key,
        'SOAPAction' => ''
      },
      namespace: ENV.fetch('siat_namespace', nil),
      convert_request_keys_to: :none
    )

    response = client.call(:verificar_comunicacion)
    if response.success?
      data = response.to_array(:verificar_comunicacion_response).first
      data = data[:return][:transaccion]
    else
      data = { return: 'Communication error' }
    end
    true if data
  rescue StandardError
    false
  end
end
