# frozen_string_literal: true

class SiatAvailable
  def self.available(invoice, contingency)
    client = Savon.client(
      wsdl: ENV.fetch('siat_invoices'.to_s, nil),
      headers: {
        'apikey' => invoice.branch_office.company.company_setting.api_key,
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
      data = { return: 'Communication error' }
    end
    data == '926'
  rescue StandardError => e
    if e.message.include?('TCP connection') && invoice.branch_office.contingencies.pending.none? && contingency == true
      create_contingency(invoice,
                         1)
    end
  end

  private

  def create_contingency(invoice, significative_event)
    @invoice.branch_office.point_of_sales.find_by(code: invoice.point_of_sale)
            .contingencies.create(start_date: invoice.date,
                                  cufd_code: invoice.cufd_code,
                                  significative_event_id: significative_event,
                                  point_of_sale_id: invoice.point_of_sale)
  end
end