# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/pages', type: :request do
  let(:valid_attributes) do
    {
      description: 'AbcCba'
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
      create(:page)
      get api_v1_system_module_pages_url(SystemModule.first.id), headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    before { create(:system_module) }
    context 'with valid parameters' do
      it 'creates a new Page' do
        expect do
          post api_v1_system_module_pages_url(SystemModule.first.id),
               params: { page: valid_attributes }, headers: @auth_headers, as: :json
        end.to change(Page, :count).by(1)
      end

      it 'renders a JSON response with the new api_v1_page' do
        post api_v1_system_module_pages_url(SystemModule.first.id),
             params: { page: valid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Page' do
        expect do
          post api_v1_system_module_pages_url(SystemModule.first.id),
               params: { page: invalid_attributes }, as: :json
        end.to change(Page, :count).by(0)
      end

      it 'renders a JSON response with errors for the new api_v1_page' do
        post api_v1_system_module_pages_url(SystemModule.first.id),
             params: { page: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end
end
