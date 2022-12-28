# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/economic_activities', type: :request do
  let(:valid_headers) do
    {}
  end

  before(:all) do
    @user = create(:user)
    @auth_headers = @user.create_new_auth_token
  end
  
  after(:all) do
    @user.destroy  
  end
  
  describe 'GET /index' do
    let(:company) { create(:company) }

    it 'renders a successful response' do
      create(:economic_activity, company: company)
      get api_v1_company_economic_activities_url(company_id: company.id), headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end
end
