# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/invoices', type: :request do
  let(:invalid_attributes) do
    {
      date: nil,
      company_name: nil,
      number: nil,
      subtotal: -1,
      total: -1
    }
  end

  let(:valid_headers) do
    {}
  end

  describe 'GET /show' do
    let(:invoice) { create(:invoice) }

    it 'renders a successful response' do
      get api_v1_invoice_url(invoice), as: :json
      expect(response).to be_successful
    end
  end

  describe 'PUT /update' do
    context 'with valid parameters' do
      let(:new_attributes) { { business_name: 'ABC' } }
      let(:invoice) { create(:invoice) }

      it 'updates the requested invoice' do
        put api_v1_invoice_url(invoice),
            params: { invoice: new_attributes }, headers: valid_headers, as: :json
        invoice.reload
        expect(invoice.business_name).to eq('ABC')
      end

      it 'renders a JSON response with the api_v1_invoice' do
        put api_v1_invoice_url(invoice),
            params: { invoice: new_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      let(:invoice) { create(:invoice) }

      it 'renders a JSON response with errors for the api_v1_invoice' do
        put api_v1_invoice_url(invoice),
            params: { invoice: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested api_v1_invoice' do
      invoice = create(:invoice)
      expect do
        delete api_v1_invoice_url(invoice), headers: valid_headers, as: :json
      end.to change(Invoice, :count).by(-1)
    end
  end
end
