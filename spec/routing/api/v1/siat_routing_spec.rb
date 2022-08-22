# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ProductsController, type: :routing do
  describe 'routing' do
    it 'routes to #generate_cuis' do
      expect(post: '/api/v1/branch_offices/1/siat/generate_cuis').to route_to('api/v1/siat#generate_cuis', branch_office_id: '1')
    end

    it 'routes to #show_cuis' do
      expect(get: '/api/v1/branch_offices/1/siat/show_cuis').to route_to('api/v1/siat#show_cuis', branch_office_id: '1')
    end

    it 'routes to #generate_cufd' do
      expect(post: '/api/v1/branch_offices/1/siat/generate_cufd').to route_to('api/v1/siat#generate_cufd', branch_office_id: '1')
    end

    it 'routes to #show_cufd' do
      expect(get: '/api/v1/branch_offices/1/siat/show_cufd').to route_to('api/v1/siat#show_cufd', branch_office_id: '1')
    end

    it 'routes to #product_codes' do
      expect(post: '/api/v1/branch_offices/1/siat/product_codes').to route_to('api/v1/siat#product_codes', branch_office_id: '1')
    end

    it 'routes to #economic_activities' do
      expect(post: '/api/v1/branch_offices/1/siat/economic_activities').to route_to('api/v1/siat#economic_activities',
                                                                                    branch_office_id: '1')
    end

    it 'routes to #document_types' do
      expect(post: '/api/v1/branch_offices/1/siat/document_types').to route_to('api/v1/siat#document_types',
                                                                               branch_office_id: '1')
    end

    it 'routes to #payment_methods' do
      expect(post: '/api/v1/branch_offices/1/siat/payment_methods').to route_to('api/v1/siat#payment_methods',
                                                                                branch_office_id: '1')
    end

    it 'routes to #legends' do
      expect(post: '/api/v1/branch_offices/1/siat/legends').to route_to('api/v1/siat#legends', branch_office_id: '1')
    end
  end
end
