# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/daily_codes', type: :request do
  let(:invalid_attributes) do
    {
      code: nil
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
    let(:daily_code) { create(:daily_code) }

    it 'renders a successful response' do
      get api_v1_daily_code_url(daily_code), headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'PUT /update' do
    context 'with valid parameters' do
      let(:new_attributes) { { code: '456' } }
      let(:daily_code) { create(:daily_code) }

      it 'updates the requested daily_code' do
        put api_v1_daily_code_url(daily_code),
            params: { daily_code: new_attributes }, headers: @auth_headers, as: :json
        daily_code.reload
        expect(daily_code.code).to eq('456')
      end

      it 'renders a JSON response with the daily_code' do
        put api_v1_daily_code_url(daily_code),
            params: { daily_code: new_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      let(:daily_code) { create(:daily_code) }

      it 'renders a JSON response with errors for the daily_code' do
        put api_v1_daily_code_url(daily_code),
            params: { daily_code: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested api_v1_daily_code' do
      daily_code = create(:daily_code)
      expect do
        delete api_v1_daily_code_url(daily_code), headers: @auth_headers, as: :json
      end.to change(DailyCode, :count).by(-1)
    end
  end
end
