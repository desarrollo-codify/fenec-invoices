# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::InvoicesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/branch_offices/1/invoices').to route_to('api/v1/invoices#index', branch_office_id: '1')
    end

    it 'routes to #show' do
      expect(get: '/api/v1/invoices/1').to route_to('api/v1/invoices#show', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/api/v1/branch_offices/1/invoices').to route_to('api/v1/invoices#create', branch_office_id: '1')
    end

    it 'routes to #update via PUT' do
      expect(put: '/api/v1/invoices/1').to route_to('api/v1/invoices#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/api/v1/invoices/1').to route_to('api/v1/invoices#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/api/v1/invoices/1').to route_to('api/v1/invoices#destroy', id: '1')
    end

    it 'routes to #resend' do
      expect(post: '/api/v1/invoices/1/resend').to route_to('api/v1/invoices#resend', id: '1')
    end

    it 'routes to #cancel' do
      expect(post: '/api/v1/invoices/1/cancel').to route_to('api/v1/invoices#cancel', id: '1')
    end

    it 'routes to #verify_status' do
      expect(post: '/api/v1/invoices/1/verify_status').to route_to('api/v1/invoices#verify_status', id: '1')
    end
  end
end
