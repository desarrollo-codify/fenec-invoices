# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::SignificativeEventsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/significative_events').to route_to('api/v1/significative_events#index')
    end
  end
end
