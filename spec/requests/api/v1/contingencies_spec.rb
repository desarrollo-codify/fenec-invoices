# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Contingencies', type: :request do
  let(:invalid_attributes) do
    {
      start_date: nil
    }
  end

  before(:all) do
    @user = create(:user)
    @auth_headers = @user.create_new_auth_token
  end
  
  after(:all) do
    @user.destroy  
  end

  describe 'GET /show' do
    let(:contingency) { create(:contingency) }

    it 'renders a successful response' do
      get api_v1_contingency_url(contingency), headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'PUT /update' do
    context 'with valid parameters' do
      let(:new_attributes) { { end_date: '2022-08-31' } }
      let(:contingency) { create(:contingency) }

      it 'updates the requested contingency' do
        put api_v1_contingency_url(contingency),
            params: { contingency: new_attributes }, headers: @auth_headers, as: :json
        contingency.reload
        expect(contingency.end_date.strftime('%Y-%m-%d')).to eq('2022-08-31')
      end

      it 'renders a JSON response with the contingency' do
        put api_v1_contingency_url(contingency),
            params: { contingency: new_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      let(:contingency) { create(:contingency) }

      it 'renders a JSON response with errors for the contingency' do
        put api_v1_contingency_url(contingency),
            params: { contingency: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested contingency' do
      contingency = create(:contingency)
      expect do
        delete api_v1_contingency_url(contingency), headers: @auth_headers, as: :json
      end.to change(Contingency, :count).by(-1)
    end
  end
end
