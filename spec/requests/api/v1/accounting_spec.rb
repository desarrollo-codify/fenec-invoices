require 'rails_helper'

RSpec.describe "api/v1/accountings", type: :request do
  describe "GET /currencies" do
    it "returns http success" do
      get "/accounting/currencies"
      expect(response).to have_http_status(:success)
    end
  end

end
