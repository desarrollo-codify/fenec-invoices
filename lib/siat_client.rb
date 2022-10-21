# frozen_string_literal: true

require 'savon'

class SiatClient
  def self.client(wsdl_name, company)
    wsdl_name = "pilot_#{wsdl_name}" if company.environment_type_id == 2
    Savon.client(
      wsdl: ENV.fetch(wsdl_name.to_s, nil),
      headers: {
        'apikey' => company.company_setting.api_key,
        'SOAPAction' => ''
      },
      namespace: ENV.fetch('siat_namespace', nil),
      convert_request_keys_to: :none
    )
  end
end
