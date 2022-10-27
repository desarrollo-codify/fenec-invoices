# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::GlobalSettingsController, type: :routing do
  describe 'routing' do
    it 'routes to #significative_events' do
      expect(get: '/api/v1/global_settings/significative_events').to route_to('api/v1/global_settings#significative_events')
    end

    it 'routes to #countries' do
      expect(get: '/api/v1/global_settings/countries').to route_to('api/v1/global_settings#countries')
    end

    it 'routes to #cancellation_reasons' do
      expect(get: '/api/v1/global_settings/cancellation_reasons').to route_to('api/v1/global_settings#cancellation_reasons')
    end

    it 'routes to #document_types' do
      expect(get: '/api/v1/global_settings/document_types').to route_to('api/v1/global_settings#document_types')
    end

    it 'routes to #issuance_types' do
      expect(get: '/api/v1/global_settings/issuance_types').to route_to('api/v1/global_settings#issuance_types')
    end

    it 'routes to #room_types' do
      expect(get: '/api/v1/global_settings/room_types').to route_to('api/v1/global_settings#room_types')
    end

    it 'routes to #payment_methods' do
      expect(get: '/api/v1/global_settings/payment_methods').to route_to('api/v1/global_settings#payment_methods')
    end

    it 'routes to #currency_types' do
      expect(get: '/api/v1/global_settings/currency_types').to route_to('api/v1/global_settings#currency_types')
    end

    it 'routes to #pos_types' do
      expect(get: '/api/v1/global_settings/pos_types').to route_to('api/v1/global_settings#pos_types')
    end

    it 'routes to #invoice_types' do
      expect(get: '/api/v1/global_settings/invoice_types').to route_to('api/v1/global_settings#invoice_types')
    end

    it 'routes to #measurement_types' do
      expect(get: '/api/v1/global_settings/measurement_types').to route_to('api/v1/global_settings#measurement_types')
    end

    it 'routes to #service_messages' do
      expect(get: '/api/v1/global_settings/service_messages').to route_to('api/v1/global_settings#service_messages')
    end

    it 'routes to #document_sector_types' do
      expect(get: '/api/v1/global_settings/document_sector_types').to route_to('api/v1/global_settings#document_sector_types')
    end

    it 'routes to #product_codes' do
      expect(get: '/api/v1/global_settings/product_codes').to route_to('api/v1/global_settings#product_codes')
    end
  end
end
