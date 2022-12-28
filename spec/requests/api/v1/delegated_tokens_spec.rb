# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::DelegatedTokens', type: :request do
  let(:invalid_attributes) do
    {
      token: nil,
      expiration_date: nil
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
    let(:delegated_token) { create(:delegated_token) }

    it 'renders a successful response' do
      get api_v1_delegated_token_url(delegated_token), headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'PUT /update' do
    context 'with valid parameters' do
      let(:new_attributes) { { token: '456', expiration_date: '2022-08-01' } }
      let(:delegated_token) { create(:delegated_token) }

      it 'updates the requested delegated_token' do
        put api_v1_delegated_token_url(delegated_token),
            params: { delegated_token: new_attributes }, headers: @auth_headers, as: :json
        delegated_token.reload
        expect(delegated_token.token).to eq('456')
      end

      it 'renders a JSON response with the delegated_token' do
        put api_v1_delegated_token_url(delegated_token),
            params: { delegated_token: new_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      let(:delegated_token) { create(:delegated_token) }

      it 'renders a JSON response with errors for the delegated_token' do
        put api_v1_delegated_token_url(delegated_token),
            params: { delegated_token: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested api_v1_delegated_token' do
      delegated_token = create(:delegated_token)
      expect do
        delete api_v1_delegated_token_url(delegated_token), headers: @auth_headers, as: :json
      end.to change(DelegatedToken, :count).by(-1)
    end
  end
end
