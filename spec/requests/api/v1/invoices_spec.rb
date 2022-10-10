# frozen_string_literal: true

require 'rails_helper'
require 'siat_available'

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

  describe 'POST /cancel' do
    let(:invoice) { create(:invoice) }

    before(:each) do
      create(:cancellation_reason, code: 2)
      create(:invoice_status, description: 'Anulado')
    end

    it 'destroys the requested api_v1_invoice' do
      post cancel_api_v1_invoice_url(invoice), headers: valid_headers, as: :json
      expect(invoice.invoice_status_id).to eq(2)
    end
  end

  describe 'POST /resend' do
    let(:invoice) { create(:invoice) }

    let(:params) do
      {
        client: OpenStruct.new(
          {
            code: '055',
            email: 'carlos.gutierrez@codify.com.bo'
          }
        ),
        invoice: OpenStruct.new(
          {
            business_name: 'Codify',
            business_nit: 123_456,
            number: 1,
            total: 100,
            date: '2022-08-26 16:00:00'.to_datetime,
            cuf: 'abc123',
            emailed_at: ''
          }
        ),
        sender: OpenStruct.new(
          {
            user_name: 'carlos.gutierrez@codify.com.bo',
            password: 'password',
            domain: 'codify.com.bo',
            port: 465,
            address: 'codify.com.bo'
          }
        )
      }
    end

    let(:mail) { InvoiceMailer.with(params).send_invoice }

    it 'resend the requested api_v1_invoice' do
      post resend_api_v1_invoice_url(invoice), headers: valid_headers, as: :json
      xml_path = "#{Rails.root}/public/tmp/mails/abc123.xml"
      pdf_path = "#{Rails.root}/public/tmp/mails/abc123.pdf"
      File.write(xml_path, 'hola')
      File.write(pdf_path, '')

      expect(response).to have_http_status(:ok)
    end

    it 'renders the headers to invoices' do
      expect(mail.subject).to eq('Factura')
      expect(mail.to).to eq(['carlos.gutierrez@codify.com.bo'])
      expect(mail.from).to eq(['carlos.gutierrez@codify.com.bo'])
    end
    # TODO: Verify spect mailer
    # it ' mail ' do
    #   expect_mailer_call(InvoiceMailer, :send_invoice)
    # end
  end
end
