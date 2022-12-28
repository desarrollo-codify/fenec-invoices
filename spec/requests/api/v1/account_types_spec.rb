# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::AccountTypes', type: :request do
  before do
    @user = create(:user)
  end

  after do
    @user.destroy
  end
  describe 'GET /index' do
    it 'returns http success' do
      auth_headers = @user.create_new_auth_token
      get '/api/v1/account_types', headers: auth_headers, as: :json
      expect(response).to have_http_status(:success)
    end
  end
end
