# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::LegendsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/economic_activities/1/document_types').to route_to('api/v1/document_types#index',
                                                                              economic_activity_id: 1)
    end
  end
end
