# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::AccountLevels', type: :request do
  describe 'GET /index' do
    before do
      @user = create(:user)
    end
  
    after do
      @user.destroy
    end
    it 'returns http success' do
      auth_headers = @user.create_new_auth_token
      get '/api/v1/account_levels', headers: auth_headers, as: :json
      expect(response).to have_http_status(:success)
    end
  end
end
