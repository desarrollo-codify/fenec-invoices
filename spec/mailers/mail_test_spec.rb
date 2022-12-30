# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MailTestMailer, type: :mailer do
  describe 'send_mail' do
    let(:params) do
      {
        email: 'carlos.gutierrez@codify.com.bo',
        company: OpenStruct.new(
          {
            name: 'Company',
            company_setting: OpenStruct.new(
              {
                user_name: 'carlos.gutierrez@codify.com.bo',
                password: 'password',
                domain: 'codify.com.bo',
                port: 465,
                address: 'codify.com.bo'
              }
            )
          }
        )
      }
    end
    let(:mail) { MailTestMailer.with(params).send_mail }

    it 'renders the headers' do
      expect(mail.subject).to eq('Correo de verificación')
      expect(mail.to).to eq(['carlos.gutierrez@codify.com.bo'])
      expect(mail.from).to eq(['carlos.gutierrez@codify.com.bo'])
    end
  end
end
