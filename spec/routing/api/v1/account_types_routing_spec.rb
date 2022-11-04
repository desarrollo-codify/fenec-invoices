# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::AccountTypesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/account_types').to route_to('api/v1/account_types#index')
    end
  end
end
