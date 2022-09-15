require 'rails_helper'

RSpec.describe "Api::V1::CuisCodes", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/api/v1/cuis_codes/show"
      expect(response).to have_http_status(:success)
    end
  end

end
