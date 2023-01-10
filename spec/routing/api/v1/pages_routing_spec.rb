# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::PagesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/system_modules/1/pages').to route_to('api/v1/pages#index', system_module_id: '1')
    end

    it 'routes to #show' do
      expect(get: '/api/v1/pages/1').to route_to('api/v1/pages#show', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/api/v1/system_modules/1/pages').to route_to('api/v1/pages#create', system_module_id: '1')
    end

    it 'routes to #update via PUT' do
      expect(put: '/api/v1/pages/1').to route_to('api/v1/pages#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/api/v1/pages/1').to route_to('api/v1/pages#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/api/v1/pages/1').to route_to('api/v1/pages#destroy', id: '1')
    end
  end
end
