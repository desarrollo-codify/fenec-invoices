# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/system_modules', type: :request do
  let(:valid_attributes) do
    {
      description: 'Abc'
    }
  end

  let(:invalid_attributes) do
    {
      description: nil
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
      create(:system_module)
      get api_v1_system_modules_url, headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      system_module = create(:system_module)
      get api_v1_system_module_url(system_module), headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new SystemModule' do
        expect do
          post api_v1_system_modules_url,
               params: { system_module: valid_attributes }, headers: @auth_headers, as: :json
        end.to change(SystemModule, :count).by(1)
      end

      it 'renders a JSON response with the new api_v1_system_module' do
        post api_v1_system_modules_url,
             params: { system_module: valid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new SystemModule' do
        expect do
          post api_v1_system_modules_url,
               params: { system_module: invalid_attributes }, as: :json
        end.to change(SystemModule, :count).by(0)
      end

      it 'renders a JSON response with errors for the new api_v1_system_module' do
        post api_v1_system_modules_url,
             params: { system_module: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) { { description: 'new description' } }

      it 'updates the requested api_v1_system_module' do
        system_module = create(:system_module)
        patch api_v1_system_module_url(system_module),
              params: { system_module: new_attributes }, headers: @auth_headers, as: :json
        system_module.reload
        expect(system_module.description).to eq('new description')
      end

      it 'renders a JSON response with the api_v1_system_module' do
        system_module = create(:system_module)
        patch api_v1_system_module_url(system_module),
              params: { system_module: new_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'renders a JSON response with errors for the api_v1_system_module' do
        system_module = create(:system_module)
        patch api_v1_system_module_url(system_module),
              params: { system_module: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested api_v1_system_module' do
      system_module = create(:system_module)
      expect do
        delete api_v1_system_module_url(system_module), headers: @auth_headers, as: :json
      end.to change(SystemModule, :count).by(-1)
    end
  end
end
