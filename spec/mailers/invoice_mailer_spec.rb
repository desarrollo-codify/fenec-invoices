# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoiceMailer, type: :mailer do
  describe 'send_invoice' do
    let(:params) do
      {
        client: OpenStruct.new(
          {
            code: '055',
            email: 'carlos.gutierrez@codify.com.bo',
          }),
        invoice: OpenStruct.new(
          {
            business_name: 'Codify',
            business_nit: 123456,
            number: 1,
            total: 100,
            date: '2022-08-26 16:00:00'.to_datetime,
            cuf: 'abc123',
            emailed_at: ''
          }),
        sender: OpenStruct.new(
          {
            user_name: 'carlos.gutierrez@codify.com.bo',
            password: 'password',
            domain: 'codify.com.bo',
            port: 465,
            address: 'codify.com.bo',
          })
      }
    end
    xml_path = "#{Rails.root}/public/tmp/mails/abc123.xml"
    pdf_path = "#{Rails.root}/public/tmp/mails/abc123.pdf"
    File.open(xml_path, 'w') do |file|
      file.write('hola')
    end
    File.open(pdf_path, 'w') do |file|
      file.write('')
    end
    debugger
    let(:mail) { InvoiceMailer.with(params).send_invoice }

    it 'renders the headers' do
      expect(mail.subject).to eq('Factura')
      expect(mail.to).to eq(['carlos.gutierrez@codify.com.bo'])
      expect(mail.from).to eq(['carlos.gutierrez@codify.com.bo'])
    end
    # File.delete(xml_path)
  end
end
