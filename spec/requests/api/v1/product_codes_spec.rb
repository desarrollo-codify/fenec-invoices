# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::ProductCodes', type: :request do
  before(:all) do
    @user = create(:user)
    @auth_headers = @user.create_new_auth_token
  end

  after(:all) do
    @user.destroy
  end

  describe 'GET /index' do
    let(:economic_activity) { create(:economic_activity) }
    it 'returns http success' do
      create(:product_code, economic_activity: economic_activity)
      get '/api/v1/economic_activities/1/product_codes', headers: @auth_headers
      expect(response).to have_http_status(:success)
    end
  end
end
