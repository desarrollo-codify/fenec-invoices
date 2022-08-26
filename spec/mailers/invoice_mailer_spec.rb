# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoiceMailer, type: :mailer do
  # describe 'send_invoice' do
  #   let(:params) do
  #     {
  #       client: [
  #         {
  #           code: '055',
  #           email: 'example@example.com',
  #         }
  #       ],
  #       invoice: [
  #         {
  #           business_name: 'Codify',
  #           business_nit: 123456,
  #           number: 1,
  #           total: 100,
  #           date: '2022-08-26',
  #         }
  #       ],
  #       xml: [
  #           Nokogiri::XML::Builder.new do |xml|
  #             xml.cabecera do
  #               xml.nitEmisor '12345'
  #               xml.razonSocialEmisor 'Codify'
  #             end
  #           end
  #       ]
  #     }
  #   end

  #   let(:mail) { InvoiceMailer.send_invoice(:params) }

  #   it 'renders the headers' do
  #     expect(mail.subject).to eq('Factura')
  #     expect(mail.to).to eq(['carlos.gutierrez@codify.com.bo'])
  #     expect(mail.from).to eq([:params.client.email])
  #   end
  # end
end
