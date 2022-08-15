# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/branch_offices/:branch_office_id/invoices', type: :request do
  let(:invoice_status) { create(:invoice_status) }
  let(:valid_attributes) do
    {
      date: '2022-01-01',
      company_name: 'SRL',
      number: 1,
      subtotal: 1,
      total: 1,
      cash_paid: 1,
      invoice_status_id: invoice_status.id
    }
  end

  let(:invalid_attributes) do
    {
      business_name: nil,
      subtotal: -1,
      total: -1
    }
  end

  let(:valid_headers) do
    {}
  end

  describe 'GET /index' do
    let(:branch_office) { create(:branch_office) }

    it 'renders a successful response' do
      create(:invoice, branch_office: branch_office)
      get api_v1_branch_office_invoices_url(branch_office_id: branch_office.id), headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    let(:branch_office) { create(:branch_office) }

    context 'with valid parameters' do
      it 'creates a new Invoice' do
        expect do
          post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
               params: { invoice: valid_attributes }, headers: valid_headers, as: :json
        end.to change(Invoice, :count).by(1)
      end

      it 'renders a JSON response with the new api_v1_branch_office' do
        post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
             params: { invoice: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Invoice' do
        expect do
          post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
               params: { invoice: invalid_attributes }, as: :json
        end.to change(Invoice, :count).by(0)
      end

      it 'renders a JSON response with errors for the new api_v1_company_branch_office' do
        post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
             params: { invoice: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end
end
