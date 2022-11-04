# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::AccountLevelsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/account_levels').to route_to('api/v1/account_levels#index')
    end
  end
end
