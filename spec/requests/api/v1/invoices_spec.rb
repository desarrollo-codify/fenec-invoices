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

  before(:all) do
    @user = create(:user)
    @auth_headers = @user.create_new_auth_token
  end
  
  after(:all) do
    @user.destroy  
  end

  describe 'GET /show' do
    let(:invoice) { build(:invoice) }

    context 'is valid' do
      before { create(:payment_method) }
      it 'renders a successful response' do
        invoice.payments.build(mount: 1, payment_method_id: 1)
        invoice.save
        get api_v1_invoice_url(invoice),headers: @auth_headers, as: :json
        expect(response).to be_successful
      end
    end
  end

  describe 'PUT /update' do
    context 'with valid parameters' do
      let(:new_attributes) { { business_name: 'ABC' } }
      let(:invoice) { build(:invoice) }
      before { create(:payment_method) }

      before(:each) do
        invoice.payments.build(mount: 1, payment_method_id: 1)
        invoice.save
      end

      it 'updates the requested invoice' do
        put api_v1_invoice_url(invoice),
            params: { invoice: new_attributes },headers: @auth_headers, as: :json
        invoice.reload
        expect(invoice.business_name).to eq('ABC')
      end

      it 'renders a JSON response with the api_v1_invoice' do
        put api_v1_invoice_url(invoice),
            params: { invoice: new_attributes },headers: @auth_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      let(:invoice) { build(:invoice) }
      before { create(:payment_method) }

      before(:each) do
        invoice.payments.build(mount: 1, payment_method_id: 1)
        invoice.save
      end

      it 'renders a JSON response with errors for the api_v1_invoice' do
        put api_v1_invoice_url(invoice),
            params: { invoice: invalid_attributes },headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'DELETE /destroy' do
    let(:invoice) { build(:invoice) }
    before { create(:payment_method) }

    before(:each) do
      invoice.payments.build(mount: 1, payment_method_id: 1)
      invoice.save
    end

    it 'destroys the requested api_v1_invoice' do
      expect do
        delete api_v1_invoice_url(invoice),headers: @auth_headers, as: :json
      end.to change(Invoice, :count).by(-1)
    end
  end

  describe 'POST /cancel' do
    context 'with Siat available' do
      before(:each) do
        create(:cancellation_reason, code: 1)
        create(:invoice_status, description: 'Anulado')
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow_any_instance_of(CancelInvoiceJob).to receive(:send_to_siat).and_return(true)
      end

      let(:branch_office) { create(:branch_office) }
      before { create(:cuis_code, branch_office: branch_office) }
      before { create(:daily_code, branch_office: branch_office) }
      let(:economic_activity) { create(:economic_activity, company: branch_office.company) }
      before { create(:legend, economic_activity: economic_activity) }
      before { create(:measurement) }
      before { create(:product, company: branch_office.company) }
      before { create(:invoice_status) }
      before { create(:client, company: branch_office.company) }
      before { create(:company_setting, company: branch_office.company) }
      let(:invoice) do
        build(:invoice, branch_office: branch_office, client_code: '00001', sent_at: '2022-10-17', invoice_status_id: 1)
      end

      before { create(:payment_method) }

      before(:each) do
        invoice.payments.build(mount: 1, payment_method_id: 1)
        invoice.save
      end

      it 'cancel invoices' do
        post cancel_api_v1_invoice_url(invoice), params: { reason: 1 },headers: @auth_headers, as: :json
        invoice_expect = Invoice.find(invoice.id)
        expect(invoice_expect.cancel_sent_at).to be_truthy
        expect(invoice_expect.invoice_status_id).to eq(2)
      end
    end

    context 'with Siat is not available' do
      before(:each) do
        create(:cancellation_reason, code: 2)
        create(:invoice_status, description: 'Anulado')
        allow(SiatAvailable).to receive(:available).and_return(false)
        allow_any_instance_of(CancelInvoiceJob).to receive(:send_to_siat).and_return(true)
      end

      let(:branch_office) { create(:branch_office) }
      before { create(:cuis_code, branch_office: branch_office) }
      before { create(:daily_code, branch_office: branch_office) }
      let(:economic_activity) { create(:economic_activity, company: branch_office.company) }
      before { create(:legend, economic_activity: economic_activity) }
      before { create(:measurement) }
      before { create(:product, company: branch_office.company) }
      before { create(:invoice_status) }
      before { create(:client, company: branch_office.company) }
      before { create(:company_setting, company: branch_office.company) }
      let(:invoice) do
        build(:invoice, branch_office: branch_office, client_code: '00001', sent_at: '2022-10-17', invoice_status_id: 1)
      end

      before { create(:payment_method) }

      before(:each) do
        invoice.payments.build(mount: 1, payment_method_id: 1)
        invoice.save
      end

      it 'cancel invoices' do
        post cancel_api_v1_invoice_url(invoice), params: { reason: 1 },headers: @auth_headers, as: :json
        invoice_expect = Invoice.find(invoice.id)
        expect(invoice_expect.cancel_sent_at).to be(nil)
        expect(invoice_expect.invoice_status_id).to eq(2)
      end
    end
  end

  describe 'POST /resend' do
    let(:branch_office) { create(:branch_office) }
    before { create(:cuis_code, branch_office: branch_office) }
    before { create(:daily_code, branch_office: branch_office) }
    let(:economic_activity) { create(:economic_activity, company: branch_office.company) }
    before { create(:legend, economic_activity: economic_activity) }
    before { create(:measurement) }
    before { create(:product, company: branch_office.company) }
    before { create(:invoice_status) }
    before { create(:client, company: branch_office.company) }
    before { create(:company_setting, company: branch_office.company) }
    let(:invoice) { build(:invoice, branch_office: branch_office, client_code: '00001') }

    before { create(:payment_method) }

    before(:each) do
      invoice.payments.build(mount: 1, payment_method_id: 1)
      invoice.save
    end

    xml_path = "#{Rails.root}/public/tmp/mails/abc.xml"
    pdf_path = "#{Rails.root}/public/tmp/mails/abc.pdf"
    File.write(xml_path, 'hola')
    File.write(pdf_path, '')

    it 'resend the requested api_v1_invoice' do
      post resend_api_v1_invoice_url(invoice),headers: @auth_headers, as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /verify_status' do
    let(:branch_office) { create(:branch_office) }
    before { create(:cuis_code, branch_office: branch_office) }
    before { create(:daily_code, branch_office: branch_office) }
    let(:economic_activity) { create(:economic_activity, company: branch_office.company) }
    before { create(:legend, economic_activity: economic_activity) }
    before { create(:measurement) }
    before { create(:product, company: branch_office.company) }
    before { create(:invoice_status) }
    before { create(:client, company: branch_office.company) }
    before { create(:company_setting, company: branch_office.company) }
    let(:invoice) { build(:invoice, branch_office: branch_office, client_code: '00001') }
    before { create(:payment_method) }

    before(:each) do
      invoice.payments.build(mount: 1, payment_method_id: 1)
      invoice.save
    end

    response = { codigo_descripcion: 'VALIDA', codigo_estado: '908', transaccion: true }

    before(:each) do
      allow_any_instance_of(InvoiceStatusJob).to receive(:send_siat).and_return(response)
    end

    it 'verifies the invoice status at the Siat platform' do
      expect do
        post verify_status_api_v1_invoice_url(invoice),headers: @auth_headers, as: :json
      end.to change(invoice.invoice_logs, :count).by(1)
    end
  end

  describe 'GET /logs' do
    let(:invoice) { build(:invoice) }
    before { create(:payment_method) }

    before(:each) do
      invoice.payments.build(mount: 1, payment_method_id: 1)
      invoice.save
    end
    let(:invoice_log) { create(:invoice_log) }

    it 'renders a successful response' do
      get logs_api_v1_invoice_url(invoice),headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end
end
