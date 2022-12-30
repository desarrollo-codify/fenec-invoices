# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::EmailVerificationsController, type: :controller do
  describe 'POST #confirm_email' do
    context 'when the confirm token is valid' do
      it 'activates the email' do
        company_setting = create(:company_setting, confirm_token: 'valid_token')

        post :confirm_email, params: { id: 'valid_token' }

        expect(company_setting.reload.email_activate).to be true
      end

      it 'returns a success message' do
        create(:company_setting, confirm_token: 'valid_token')

        post :confirm_email, params: { id: 'valid_token' }

        expect(response.body).to eq({ message: 'Se ha verificado correctamente la configuración del correo.' }.to_json)
      end
    end

    context 'when the confirm token is invalid' do
      it 'returns an error message' do
        post :confirm_email, params: { id: 'invalid_token' }

        expect(response.body).to eq({ message: 'El enlace ya expiró.' }.to_json)
      end
    end
  end
end
