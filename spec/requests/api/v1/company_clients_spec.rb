# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/company/:company_id/clients', type: :request do
  let(:valid_attributes) do
    {
      name: 'Abc',
      nit: '123',
      code: '055',
      phone: '12345',
      email: 'example@example.com'
    }
  end

  let(:invalid_attributes) do
    {
      name: nil,
      nit: nil
    }
  end

  let(:valid_headers) do
    {}
  end

  describe 'GET /index' do
    let(:company) { create(:company) }

    it 'renders a successful response' do
      create(:client, company: company)
      get api_v1_company_clients_url(company_id: company.id), headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    let(:company) { create(:company) }

    context 'with valid parameters' do
      it 'creates a new Client' do
        expect do
          post api_v1_company_clients_url(company_id: company.id),
               params: { client: valid_attributes }, headers: valid_headers, as: :json
        end.to change(Client, :count).by(1)
      end

      it 'renders a JSON response with the new client' do
        post api_v1_company_clients_url(company_id: company.id),
             params: { client: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Client' do
        expect do
          post api_v1_company_clients_url(company_id: company.id),
               params: { client: invalid_attributes }, as: :json
        end.to change(Client, :count).by(0)
      end

      it 'renders a JSON response with errors for the new client' do
        post api_v1_company_clients_url(company_id: company.id),
             params: { client: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end
end
