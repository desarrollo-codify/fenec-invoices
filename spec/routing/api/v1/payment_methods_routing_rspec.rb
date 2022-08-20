# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::PaymentMethodsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/payment_methods').to route_to('api/v1/payment_methods#index')
    end
  end
end
