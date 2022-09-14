# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::ProductCodes', type: :request do
  describe 'GET /index' do
    let(:economic_activity) { create(:economic_activity) }
    it 'returns http success' do
      create(:product_code, economic_activity: economic_activity)
      get '/api/v1/economic_activities/1/product_codes'
      expect(response).to have_http_status(:success)
    end
  end
end
