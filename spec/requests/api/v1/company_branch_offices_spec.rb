# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/companies/:company_id/branch_offices', type: :request do
  let(:valid_attributes) do
    {
      name: 'Sucursal 1',
      number: 1,
      city: 'Santa Cruz'
    }
  end

  let(:invalid_attributes) do
    {
      name: nil,
      number: nil,
      city: nil
    }
  end

  let(:valid_headers) do
    {}
  end

  describe 'GET /index' do
    let(:company) { create(:company) }

    it 'renders a successful response' do
      create(:branch_office, company: company)
      get api_v1_company_branch_offices_url(company_id: company.id), headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    let(:company) { create(:company) }

    context 'with valid parameters' do
      it 'creates a new BranchOffice' do
        expect do
          post api_v1_company_branch_offices_url(company_id: company.id),
               params: { branch_office: valid_attributes }, headers: valid_headers, as: :json
        end.to change(BranchOffice, :count).by(1)
      end

      it 'renders a JSON response with the new api_v1_branch_office' do
        post api_v1_company_branch_offices_url(company_id: company.id),
             params: { branch_office: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new BranchOffice' do
        expect do
          post api_v1_company_branch_offices_url(company_id: company.id),
               params: { branch_office: invalid_attributes }, as: :json
        end.to change(BranchOffice, :count).by(0)
      end

      it 'renders a JSON response with errors for the new api_v1_company_branch_office' do
        post api_v1_company_branch_offices_url(company_id: company.id),
             params: { branch_office: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end
end
