# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Orders', type: :request do
  describe 'GET /update' do
    it 'returns http success' do
      get '/api/v1/orders/update'
      expect(response).to have_http_status(:success)
    end
  end
end
