# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Siats', type: :request do
  describe 'GET /generate_cuis' do
    it 'returns http success' do
      get '/api/v1/siat/generate_cuis'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /show_cuis' do
    it 'returns http success' do
      get '/api/v1/siat/show_cuis'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /generate_cufd' do
    it 'returns http success' do
      get '/api/v1/siat/generate_cufd'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /show_cufd' do
    it 'returns http success' do
      get '/api/v1/siat/show_cufd'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /siat_codes' do
    it 'returns http success' do
      get '/api/v1/siat/siat_codes'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /bulk_products_update' do
    it 'returns http success' do
      get '/api/v1/siat/bulk_products_update'
      expect(response).to have_http_status(:success)
    end
  end
end
