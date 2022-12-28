# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/companies', type: :request do
  let(:valid_attributes) do
    {
      name: 'Abc',
      nit: '123',
      address: 'Abc'
    }
  end

  let(:invalid_attributes) do
    {
      name: nil,
      nit: nil,
      address: nil
    }
  end

  let(:valid_headers) do
    { 'Authorization' => "Bearer #{user.auth_token}" }
  end

  before(:all) do
    @user = create(:user)
    @auth_headers = @user.create_new_auth_token
  end

  after(:all) do
    @user.destroy
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      get api_v1_companies_url, headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    let(:company) { create(:company) }

    it 'renders a successful response' do
      get api_v1_company_url(company), headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Company' do
        expect do
          post api_v1_companies_url,
               params: { company: valid_attributes }, headers: @auth_headers, as: :json
        end.to change(Company, :count).by(1)
      end

      it 'renders a JSON response with the new company' do
        post api_v1_companies_url,
             params: { company: valid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Company' do
        expect do
          post api_v1_companies_url,
               params: { company: invalid_attributes }, headers: @auth_headers, as: :json
        end.to change(Company, :count).by(0)
      end

      it 'renders a JSON response with errors for the new company' do
        post api_v1_companies_url,
             params: { company: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'PUT /update' do
    context 'with valid parameters' do
      let(:new_attributes) { { name: 'new name' } }
      let(:company) { create(:company) }

      it 'updates the requested company' do
        put api_v1_company_url(company),
            params: { company: new_attributes }, headers: @auth_headers, as: :json
        company.reload
        expect(company.name).to eq('new name')
      end

      it 'renders a JSON response with the company' do
        put api_v1_company_url(company),
            params: { company: new_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      let(:company) { create(:company) }

      it 'renders a JSON response with errors for the company' do
        patch api_v1_company_url(company),
              params: { company: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested company' do
      company = create(:company)
      expect do
        delete api_v1_company_url(company), headers: @auth_headers, as: :json
      end.to change(Company, :count).by(-1)
    end
  end

  describe 'POST /add_invoice_types' do
    before { create(:invoice_type) }
    before { create(:invoice_type, code: 'def456') }

    it 'add invoice types company' do
      company = create(:company)
      expect do
        post add_invoice_types_api_v1_company_url(company), params: { invoice_type_ids: [1, 2] }, headers: @auth_headers, as: :json
      end.to change(company.invoice_types, :count).by(2)
    end
  end

  describe 'POST /add_document_sector_types' do
    before { create(:document_sector_type) }
    before { create(:document_sector_type, code: 'def456') }

    it 'add document sector types company' do
      company = create(:company)
      expect do
        post add_document_sector_types_api_v1_company_url(company), params: { document_sector_type_ids: [1, 2] },
                                                                    headers: @auth_headers, as: :json
      end.to change(company.document_sector_types, :count).by(2)
    end
  end

  describe 'POST /add_measurements' do
    before { create(:measurement) }
    before { create(:measurement, description: 'abcdef') }

    it 'add measurements company' do
      company = create(:company)
      expect do
        post add_measurements_api_v1_company_url(company), params: { measurements_ids: [1, 2] }, headers: @auth_headers, as: :json
      end.to change(company.measurements, :count).by(2)
    end
  end

  describe 'POST /remove_invoice_type' do
    before { create(:invoice_type) }
    before { create(:invoice_type, code: 'def456') }

    it 'add invoice types company' do
      company = create(:company)
      post add_invoice_types_api_v1_company_url(company), params: { invoice_type_ids: [1, 2] }, headers: @auth_headers, as: :json
      expect do
        post remove_invoice_type_api_v1_company_url(company), params: { invoice_type_id: 2 }, headers: @auth_headers, as: :json
      end.to change(company.invoice_types, :count).by(-1)
    end
  end

  describe 'POST /remove_invoice_type' do
    before { create(:invoice_type) }
    before { create(:invoice_type, code: 'def456') }

    it 'remove invoice types the company' do
      company = create(:company)
      post add_invoice_types_api_v1_company_url(company), params: { invoice_type_ids: [1, 2] }, headers: @auth_headers, as: :json
      expect do
        post remove_invoice_type_api_v1_company_url(company), params: { invoice_type_id: 2 }, headers: @auth_headers, as: :json
      end.to change(company.invoice_types, :count).by(-1)
    end
  end

  describe 'POST /remove_document_sector_type' do
    before { create(:document_sector_type) }
    before { create(:document_sector_type, code: 'def456') }

    it 'remove document sector types the company' do
      company = create(:company)
      post add_document_sector_types_api_v1_company_url(company), params: { document_sector_type_ids: [1, 2] },
                                                                  headers: @auth_headers, as: :json
      expect do
        post remove_document_sector_type_api_v1_company_url(company), params: { document_sector_type_id: 2 }, headers: @auth_headers,
                                                                      as: :json
      end.to change(company.document_sector_types, :count).by(-1)
    end
  end

  describe 'POST /remove_measurenment' do
    before { create(:measurement) }
    before { create(:measurement, description: 'def456') }

    it 'remove measurement the company' do
      company = create(:company)
      post add_measurements_api_v1_company_url(company), params: { measurements_ids: [1, 2] }, headers: @auth_headers, as: :json
      expect do
        post remove_measurements_api_v1_company_url(company), params: { measurement_id: 2 }, headers: @auth_headers, as: :json
      end.to change(company.measurements, :count).by(-1)
    end
  end
end
