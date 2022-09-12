require 'rails_helper'

RSpec.describe "Api::V1::ContingencyCodes", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/api/v1/contingency_codes/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/api/v1/contingency_codes/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/api/v1/contingency_codes/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/api/v1/contingency_codes/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/api/v1/contingency_codes/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
