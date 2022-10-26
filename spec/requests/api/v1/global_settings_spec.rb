# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/global_settings', type: :request do
  describe 'GET /significative_events' do
    before { create(:significative_event) }
    it 'renders a successful response' do
      get api_v1_global_settings_significative_events_url, as: :json
      expect(response).to be_successful
    end
  end

  describe 'GET /cancellation_reasons' do
    before { create(:cancellation_reason) }
    it 'renders a successful response' do
      get api_v1_global_settings_cancellation_reasons_url, as: :json
      expect(response).to be_successful
    end
  end

  describe 'GET /countries' do
    before { create(:country) }
    it 'renders a successful response' do
      get api_v1_global_settings_countries_url, as: :json
      expect(response).to be_successful
    end
  end

  describe 'GET /document_types' do
    before { create(:document_type) }
    it 'renders a successful response' do
      get api_v1_global_settings_document_types_url, as: :json
      expect(response).to be_successful
    end
  end

  describe 'GET /issuance_types' do
    before { create(:issuance_type) }
    it 'renders a successful response' do
      get api_v1_global_settings_issuance_types_url, as: :json
      expect(response).to be_successful
    end
  end

  describe 'GET /room_types' do
    before { create(:room_type) }
    it 'renders a successful response' do
      get api_v1_global_settings_room_types_url, as: :json
      expect(response).to be_successful
    end
  end

  describe 'GET /payment_methods' do
    before { create(:payment_method) }
    it 'renders a successful response' do
      get api_v1_global_settings_payment_methods_url, as: :json
      expect(response).to be_successful
    end
  end

  describe 'GET /currency_types' do
    before { create(:currency_type) }
    it 'renders a successful response' do
      get api_v1_global_settings_currency_types_url, as: :json
      expect(response).to be_successful
    end
  end

  describe 'GET /pos_types' do
    before { create(:pos_type) }
    it 'renders a successful response' do
      get api_v1_global_settings_pos_types_url, as: :json
      expect(response).to be_successful
    end
  end

  describe 'GET /invoice_types' do
    before { create(:invoice_type) }
    it 'renders a successful response' do
      get api_v1_global_settings_invoice_types_url, as: :json
      expect(response).to be_successful
    end
  end

  describe 'GET /measurement_types' do
    before { create(:measurement) }
    it 'renders a successful response' do
      get api_v1_global_settings_measurement_types_url, as: :json
      expect(response).to be_successful
    end
  end

  describe 'GET /service_messages' do
    before { create(:service_message) }
    it 'renders a successful response' do
      get api_v1_global_settings_service_messages_url, as: :json
      expect(response).to be_successful
    end
  end

  describe 'GET /document_sector_types' do
    before { create(:document_sector_type) }
    it 'renders a successful response' do
      get api_v1_global_settings_document_sector_types_url, as: :json
      expect(response).to be_successful
    end
  end

  describe 'GET /product_codes' do
    before { create(:product_code) }
    it 'renders a successful response' do
      get api_v1_global_settings_product_codes_url, as: :json
      expect(response).to be_successful
    end
  end
end
