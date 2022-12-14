# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::CustomersController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/companies/1/customers').to route_to('api/v1/customers#index', company_id: '1')
    end

    it 'routes to #create' do
      expect(post: '/api/v1/companies/1/customers').to route_to('api/v1/customers#create', company_id: '1')
    end
  end
end
