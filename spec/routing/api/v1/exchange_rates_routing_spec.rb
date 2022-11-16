# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ExchangeRatesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/companies/1/exchange_rates').to route_to('api/v1/exchange_rates#index', company_id: '1')
    end

    it 'routes to #show' do
      expect(get: '/api/v1/exchange_rates/1').to route_to('api/v1/exchange_rates#show', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/api/v1/companies/1/exchange_rates').to route_to('api/v1/exchange_rates#create', company_id: '1')
    end

    it 'routes to #update via PUT' do
      expect(put: '/api/v1/exchange_rates/1').to route_to('api/v1/exchange_rates#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/api/v1/exchange_rates/1').to route_to('api/v1/exchange_rates#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/api/v1/exchange_rates/1').to route_to('api/v1/exchange_rates#destroy', id: '1')
    end
  end
end
