# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Modalities', type: :request do
  before(:all) do
    @user = create(:user)
    @auth_headers = @user.create_new_auth_token
  end
  
  after(:all) do
    @user.destroy  
  end

  describe 'GET /index' do
    it 'returns http success' do
      get '/api/v1/modalities',headers: @auth_headers
      expect(response).to have_http_status(:success)
    end
  end
end
