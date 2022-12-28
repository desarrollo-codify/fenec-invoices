# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/economic_activities/:economic_activity_id/contingency_codes', type: :request do
  let(:valid_attributes) do
    {
      code: '123abc',
      limit: 10,
      document_sector_code: 1
    }
  end

  let(:invalid_attributes) do
    {
      code: nil,
      limit: 'A',
      document_sector_code: nil
    }
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
    let(:economic_activity) { create(:economic_activity, company: company) }

    it 'renders a successful response' do
      create(:contingency_code, economic_activity: economic_activity)
      get api_v1_economic_activity_contingency_codes_url(economic_activity_id: economic_activity.id), headers: @auth_headers,
                                                                                                      as: :json
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    let(:economic_activity) { create(:economic_activity) }

    context 'with valid parameters' do
      it 'creates a new ContingencyCode' do
        expect do
          post api_v1_economic_activity_contingency_codes_url(economic_activity_id: economic_activity.id),
               params: { contingency_code: valid_attributes }, headers: @auth_headers, as: :json
        end.to change(ContingencyCode, :count).by(1)
      end

      it 'renders a JSON response with the new api_v1_contingency_code' do
        post api_v1_economic_activity_contingency_codes_url(economic_activity_id: economic_activity.id),
             params: { contingency_code: valid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new ContingencyCode' do
        expect do
          post api_v1_economic_activity_contingency_codes_url(economic_activity_id: economic_activity.id),
               params: { contingency_code: invalid_attributes }, headers: @auth_headers, as: :json
        end.to change(ContingencyCode, :count).by(0)
      end

      it 'renders a JSON response with errors for the new api_v1_economic_activity_contingency_code' do
        post api_v1_economic_activity_contingency_codes_url(economic_activity_id: economic_activity.id),
             params: { contingency_code: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end
end
