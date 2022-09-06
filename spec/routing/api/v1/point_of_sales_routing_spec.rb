# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::PointOfSalesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/branch_offices/1/point_of_sales').to route_to('api/v1/point_of_sales#index', branch_office_id: '1')
    end

    it 'routes to #show' do
      expect(get: '/api/v1/point_of_sales/1').to route_to('api/v1/point_of_sales#show', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/api/v1/branch_offices/1/point_of_sales').to route_to('api/v1/point_of_sales#create', branch_office_id: '1')
    end

    it 'routes to #update via PUT' do
      expect(put: '/api/v1/point_of_sales/1').to route_to('api/v1/point_of_sales#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/api/v1/point_of_sales/1').to route_to('api/v1/point_of_sales#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/api/v1/point_of_sales/1').to route_to('api/v1/point_of_sales#destroy', id: '1')
    end
  end
end
