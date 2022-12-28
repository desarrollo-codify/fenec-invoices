# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  let(:valid_attributes) do
    {
      full_name: 'Abc',
      username: '123',
      role: 2,
      email: 'example@example.com',
      password: 'password',
      password_confirmation: 'password',
      company_id: nil
    }
  end

  let(:invalid_attributes) do
    {
      full_name: nil,
      username: nil,
      role: nil,
      email: nil,
      password: nil,
      password_confirmation: nil,
      company_id: nil
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
    it 'renders a successful response' do
      get api_v1_users_url, headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    let(:user) { create(:user, email: 'example@example.com') }

    it 'renders a successful response' do
      get api_v1_user_url(user), headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new User' do
        expect do
          post api_v1_users_url,
               params: { user: valid_attributes }, headers: @auth_headers, as: :json
        end.to change(User, :count).by(1)
      end

      it 'renders a JSON response with the new user' do
        post api_v1_users_url,
             params: { user: valid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new user' do
        expect do
          post api_v1_users_url,
               params: { user: invalid_attributes }, headers: @auth_headers, as: :json
        end.to change(Company, :count).by(0)
      end

      it 'renders a JSON response with errors for the new user' do
        post api_v1_users_url,
             params: { user: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'PUT /update' do
    context 'with valid parameters' do
      let(:new_attributes) { { full_name: 'new full_name' } }
      let(:user) { create(:user, email: 'example@example.com') }

      it 'updates the requested user' do
        put api_v1_user_url(user),
            params: { user: new_attributes }, headers: @auth_headers, as: :json
        user.reload
        expect(user.full_name).to eq('new full_name')
      end

      it 'renders a JSON response with the user' do
        put api_v1_user_url(user),
            params: { user: new_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested company' do
      user = create(:user, email: 'example@example.com')
      expect do
        delete api_v1_user_url(user), headers: @auth_headers, as: :json
      end.to change(User, :count).by(-1)
    end
  end
end
