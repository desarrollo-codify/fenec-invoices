# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/exchange_rates', type: :request do
  let(:valid_attributes) do
    {
      date: '2022-01-01',
      rate: 1
    }
  end

  let(:invalid_attributes) do
    {
      date: nil,
      rate: 0
    }
  end

  before(:all) do
    @user = create(:user)
    @auth_headers = @user.create_new_auth_token
  end

  after(:all) do
    @user.destroy
  end

  describe 'GET /index' do
    let(:company) { create(:company) }

    it 'renders a successful response' do
      create(:exchange_rate, company: company)
      get api_v1_company_exchange_rates_url(company_id: company.id), headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    let(:exchange_rate) { create(:exchange_rate) }

    it 'renders a successful response' do
      get api_v1_exchange_rate_url(exchange_rate), headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    before { @company = create(:company) }

    context 'with valid parameters' do
      it 'creates a new ExchangeRate' do
        expect do
          post api_v1_company_exchange_rates_url(company_id: @company.id),
               params: { exchange_rate: valid_attributes }, headers: @auth_headers, as: :json
        end.to change(ExchangeRate, :count).by(1)
      end

      it 'renders a JSON response with the new api_v1_exchange_rate' do
        post api_v1_company_exchange_rates_url(company_id: @company.id),
             params: { exchange_rate: valid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new BranchOffice' do
        expect do
          post api_v1_company_exchange_rates_url(company_id: @company.id),
               params: { exchange_rate: invalid_attributes }, as: :json
        end.to change(ExchangeRate, :count).by(0)
      end

      it 'renders a JSON response with errors for the new api_v1_company_exchange_rate' do
        post api_v1_company_exchange_rates_url(company_id: @company.id),
             params: { exchange_rate: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) { { rate: 2 } }
      let(:exchange_rate) { create(:exchange_rate) }

      it 'updates the requested api_v1_exchange_rate' do
        patch api_v1_exchange_rate_url(exchange_rate),
              params: { exchange_rate: new_attributes }, headers: @auth_headers, as: :json
        exchange_rate.reload
        expect(exchange_rate.rate).to eq(2)
      end

      it 'renders a JSON response with the api_v1_exchange_rate' do
        exchange_rate = create(:exchange_rate)
        patch api_v1_exchange_rate_url(exchange_rate),
              params: { exchange_rate: new_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'renders a JSON response with errors for the api_v1_exchange_rate' do
        exchange_rate = create(:exchange_rate)
        patch api_v1_exchange_rate_url(exchange_rate),
              params: { exchange_rate: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested api_v1_exchange_rate' do
      exchange_rate = create(:exchange_rate)
      expect do
        delete api_v1_exchange_rate_url(exchange_rate), headers: @auth_headers, as: :json
      end.to change(ExchangeRate, :count).by(-1)
    end
  end
end
