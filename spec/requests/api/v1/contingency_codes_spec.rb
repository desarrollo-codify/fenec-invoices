# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/contingency_codes', type: :request do
  let(:invalid_attributes) do
    {
      code: nil,
      limit: 'A',
      document_sector_code: nil
    }
  end

  before(:all) do
    @user = create(:user)
    @auth_headers = @user.create_new_auth_token
  end

  after(:all) do
    @user.destroy
  end

  describe 'GET /show' do
    let(:contingency_code) { create(:contingency_code) }

    it 'renders a successful response' do
      get api_v1_contingency_code_url(contingency_code), headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'PUT /update' do
    context 'with valid parameters' do
      let(:new_attributes) { { code: 'new code' } }
      let(:contingency_code) { create(:contingency_code) }

      it 'updates the requested contingency_code' do
        put api_v1_contingency_code_url(contingency_code),
            params: { contingency_code: new_attributes }, headers: @auth_headers, as: :json
        contingency_code.reload
        expect(contingency_code.code).to eq('new code')
      end

      it 'renders a JSON response with the contingency_code' do
        put api_v1_contingency_code_url(contingency_code),
            params: { contingency_code: new_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      let(:contingency_code) { create(:contingency_code) }

      it 'renders a JSON response with errors for the contingency_code' do
        patch api_v1_contingency_code_url(contingency_code),
              params: { contingency_code: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested contingency_code' do
      contingency_code = create(:contingency_code)
      expect do
        delete api_v1_contingency_code_url(contingency_code), headers: @auth_headers, as: :json
      end.to change(ContingencyCode, :count).by(-1)
    end
  end
end
