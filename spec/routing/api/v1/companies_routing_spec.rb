# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::CompaniesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/companies').to route_to('api/v1/companies#index')
    end

    it 'routes to #show' do
      expect(get: '/api/v1/companies/1').to route_to('api/v1/companies#show', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/api/v1/companies').to route_to('api/v1/companies#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/api/v1/companies/1').to route_to('api/v1/companies#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/api/v1/companies/1').to route_to('api/v1/companies#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/api/v1/companies/1').to route_to('api/v1/companies#destroy', id: '1')
    end

    it 'routes to #logo' do
      expect(get: '/api/v1/companies/1/logo').to route_to('api/v1/companies#logo', id: '1')
    end

    it 'routes to #update_settings' do
      expect(put: '/api/v1/companies/1/settings').to route_to('api/v1/companies#update_settings', company_id: '1')
    end

    it 'routes to #cuis_codes' do
      expect(get: '/api/v1/companies/1/cuis_codes').to route_to('api/v1/companies#cuis_codes', id: '1')
    end

    it 'routes to #contingencies' do
      expect(get: '/api/v1/companies/1/contingencies').to route_to('api/v1/companies#contingencies', id: '1')
    end

    it 'routes to #add_invoice_types' do
      expect(post: '/api/v1/companies/1/add_invoice_types').to route_to('api/v1/companies#add_invoice_types', id: '1')
    end

    it 'routes to #add_document_sector_types' do
      expect(post: '/api/v1/companies/1/add_document_sector_types').to route_to('api/v1/companies#add_document_sector_types', id: '1')
    end

    it 'routes to #add_measurements' do
      expect(post: '/api/v1/companies/1/add_measurements').to route_to('api/v1/companies#add_measurements', id: '1')
    end

    it 'routes to #remove_invoice_type' do
      expect(post: '/api/v1/companies/1/remove_invoice_type').to route_to('api/v1/companies#remove_invoice_type', id: '1')
    end

    it 'routes to #remove_document_sector_type' do
      expect(post: '/api/v1/companies/1/remove_document_sector_type').to route_to('api/v1/companies#remove_document_sector_type',
                                                                                  id: '1')
    end

    it 'routes to #remove_measurements' do
      expect(post: '/api/v1/companies/1/remove_measurements').to route_to('api/v1/companies#remove_measurements', id: '1')
    end

    it 'routes to #mail_test' do
      expect(post: '/api/v1/companies/1/mail_test').to route_to('api/v1/companies#mail_test', id: '1')
    end

    it 'routes to #confirm_mail' do
      expect(post: '/api/v1/companies/1/confirm_mail').to route_to('api/v1/companies#confirm_mail', id: '1')
    end
  end
end
