# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/company/:company_id/customers', type: :request do
  let(:document_type) { create(:document_type) }

  let(:valid_attributes) do
    {
      name: 'Abc',
      nit: '123',
      code: '00001',
      phone: '12345',
      email: 'example@example.com',
      document_type_id: document_type.id
    }
  end

  let(:invalid_attributes) do
    {
      name: nil,
      nit: nil
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
      create(:customer, company: company)
      get api_v1_company_customers_url(company_id: company.id), headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    let(:company) { create(:company) }

    context 'with valid parameters' do
      it 'creates a new Customer' do
        expect do
          post api_v1_company_customers_url(company_id: company.id),
               params: { customer: valid_attributes }, headers: @auth_headers, as: :json
        end.to change(Customer, :count).by(1)
      end

      it 'renders a JSON response with the new customer' do
        post api_v1_company_customers_url(company_id: company.id),
             params: { customer: valid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Customer' do
        expect do
          post api_v1_company_customers_url(company_id: company.id),
               params: { customer: invalid_attributes }, as: :json
        end.to change(Customer, :count).by(0)
      end

      it 'renders a JSON response with errors for the new customer' do
        post api_v1_company_customers_url(company_id: company.id),
             params: { customer: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end
end
