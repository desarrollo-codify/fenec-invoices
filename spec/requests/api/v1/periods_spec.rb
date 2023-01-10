# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Periods', type: :request do
  before(:all) do
    @user = create(:user)
    @auth_headers = @user.create_new_auth_token
  end

  after(:all) do
    @user.destroy
  end

  describe 'GET /update' do
    context 'with valid parameters' do
      let(:new_attributes) { { description: 'Example' } }

      it 'renders a JSON response with the api_v1_cycle' do
        period = create(:period)
        put api_v1_period_url(period),
            params: { period: new_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end

      context 'with invalid parameters' do
        let(:invalid_attributes) { { status: nil } }

        it 'renders a JSON response with errors for the api_v1_cycle' do
          period = create(:period)
          put api_v1_period_url(period),
              params: { period: invalid_attributes }, headers: @auth_headers, as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including('application/json'))
        end
      end
    end
  end

  describe 'GET /close' do
    it 'renders a JSON response with the close_api_v1_period' do
      period = create(:period)
      post close_api_v1_period_url(period), headers: @auth_headers, as: :json
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to match(a_string_including('application/json'))
    end

    it 'renders a JSON response with the close_api_v1_period' do
      period = create(:period)
      post close_api_v1_period_url(period), headers: @auth_headers, as: :json
      period.reload
      expect(period.status).to eq('CERRADO')
    end
  end
end
