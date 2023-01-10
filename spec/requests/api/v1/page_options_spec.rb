# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/page_option_options', type: :request do
  let(:invalid_attributes) do
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

  describe 'GET /show' do
    it 'renders a successful response' do
      page_option = create(:page_option)
      get api_v1_page_option_url(page_option), headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'PUT /update' do
    context 'with valid parameters' do
      let(:new_attributes) { { description: 'new description' } }

      it 'updates the requested api_v1_page_option' do
        page_option = create(:page_option)
        put api_v1_page_option_url(page_option),
            params: { page_option: new_attributes }, headers: @auth_headers, as: :json
        page_option.reload
        expect(page_option.description).to eq('new description')
      end

      it 'renders a JSON response with the api_v1_page_option' do
        page_option = create(:page_option)
        put api_v1_page_option_url(page_option),
            params: { page_option: new_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'renders a JSON response with errors for the api_v1_page_option' do
        page_option = create(:page_option)
        put api_v1_page_option_url(page_option),
            params: { page_option: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested api_v1_page_option' do
      page_option = create(:page_option)
      expect do
        delete api_v1_page_option_url(page_option), headers: @auth_headers, as: :json
      end.to change(PageOption, :count).by(-1)
    end
  end
end
