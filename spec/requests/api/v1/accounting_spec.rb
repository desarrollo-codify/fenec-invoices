# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'api/v1/accountings', type: :request do
  before do
    @user = create(:user)
  end

  after do
    @user.destroy
  end
  describe 'GET /currencies' do
    it 'returns http success' do
      auth_headers = @user.create_new_auth_token
      get '/api/v1/accounting/currencies', headers: auth_headers, as: :json
      expect(response).to have_http_status(:success)
    end
  end
end
