require 'rails_helper'

RSpec.describe "/api/v1/economic_activities", type: :request do
  let(:valid_headers) {
    {}
  }

  describe "GET /index" do
    let(:company) { create(:company) }

    it "renders a successful response" do
      create(:economic_activity, company: company)
      get api_v1_company_economic_activities_url(company_id: company.id), headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end
end
