# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::EconomicActivitiesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/companies/1/economic_activities').to route_to('api/v1/economic_activities#index', company_id: '1')
    end
  end
end
