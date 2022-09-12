require 'rails_helper'

RSpec.describe "Api::V1::ContingencyCodes", type: :request do
  let(:valid_headers) do
    {}
  end

  describe 'GET /index' do
    let(:economic_activity) { create(:economic_activity) }

    it 'renders a successful response' do
      create(:contingency_code, economic_activity: economic_activity)
      get api_v1_economic_activity_contingency_codes_url(economic_activity_id: economic_activity.id), headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end
end
