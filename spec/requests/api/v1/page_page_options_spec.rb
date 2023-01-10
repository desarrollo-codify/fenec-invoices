# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/page_options', type: :request do
  let(:valid_attributes) do
    {
      code: 'ac',
      description: 'AbcCba'
    }
  end

  let(:invalid_attributes) do
    {
      code: nil,
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
      create(:page_option)
      get api_v1_page_page_options_url(Page.first.id), headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    before { create(:page) }
    context 'with valid parameters' do
      it 'creates a new page_option' do
        expect do
          post api_v1_page_page_options_url(Page.first.id),
               params: { page_option: valid_attributes }, headers: @auth_headers, as: :json
        end.to change(PageOption, :count).by(1)
      end

      it 'renders a JSON response with the new api_v1_page_option' do
        post api_v1_page_page_options_url(Page.first.id),
             params: { page_option: valid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new PageOption' do
        expect do
          post api_v1_page_page_options_url(Page.first.id),
               params: { page_option: invalid_attributes }, as: :json
        end.to change(PageOption, :count).by(0)
      end

      it 'renders a JSON response with errors for the new api_v1_page_option' do
        post api_v1_page_page_options_url(Page.first.id),
             params: { page_option: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end
end
