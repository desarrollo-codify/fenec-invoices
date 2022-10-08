# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CancellationInvoiceMailer, type: :mailer do
  describe 'send_invoice' do
    # rubocop:disable all
    let(:params) do
      {
        client: OpenStruct.new(
          {
            code: '055',
            email: 'carlos.gutierrez@codify.com.bo'
          }
        ),
        invoice: OpenStruct.new(
          {
            business_name: 'Codify',
            business_nit: 123_456,
            number: 1,
            total: 100,
            cancellation_date: '2022-08-26 18:00:00'.to_datetime,
            date: '2022-08-26 16:00:00'.to_datetime,
            cuf: 'abc123',
            emailed_at: ''
          }
        ),
        sender: OpenStruct.new(
          {
            user_name: 'carlos.gutierrez@codify.com.bo',
            password: 'password',
            domain: 'codify.com.bo',
            port: 465,
            address: 'codify.com.bo'
          }
        ),
        reason: OpenStruct.new(
          {
            code: 1,
            description: 'FACTURA MAL EMITIDA'
          }
        )
      }
    end
    # rubocop:enable all
    let(:mail) { CancellationInvoiceMailer.with(params).send_invoice }

    it 'renders the headers' do
      expect(mail.subject).to eq('Factura anulada')
      expect(mail.to).to eq(['carlos.gutierrez@codify.com.bo'])
      expect(mail.from).to eq(['carlos.gutierrez@codify.com.bo'])
    end
  end
end
