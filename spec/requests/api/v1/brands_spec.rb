# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/brands', type: :request do
  let(:valid_attributes) do
    {
      description: 'ABCabc'
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
      create(:brand)
      get api_v1_brands_url, headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      brand = create(:brand)
      get api_v1_brand_url(brand), headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Brand' do
        expect do
          post api_v1_brands_url,
               params: { brand: valid_attributes }, headers: @auth_headers, as: :json
        end.to change(Brand, :count).by(1)
      end

      it 'renders a JSON response with the new api_v1_brand' do
        post api_v1_brands_url,
             params: { brand: valid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Brand' do
        expect do
          post api_v1_brands_url,
               params: { brand: invalid_attributes }, headers: @auth_headers, as: :json
        end.to change(Brand, :count).by(0)
      end

      it 'renders a JSON response with errors for the new api_v1_brand' do
        post api_v1_brands_url,
             params: { brand: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) do
        {
          description: 'BCDbcd'
        }
      end

      it 'updates the requested api_v1_brand' do
        brand = create(:brand)
        patch api_v1_brand_url(brand),
              params: { brand: new_attributes }, headers: @auth_headers, as: :json
        brand.reload
        expect(brand.description).to eq('BCDbcd')
      end

      it 'renders a JSON response with the api_v1_brand' do
        brand = create(:brand)
        patch api_v1_brand_url(brand),
              params: { brand: new_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'renders a JSON response with errors for the api_v1_brand' do
        brand = create(:brand)
        patch api_v1_brand_url(brand),
              params: { brand: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested api_v1_brand' do
      brand = create(:brand)
      expect do
        delete api_v1_brand_url(brand), headers: @auth_headers, as: :json
      end.to change(Brand, :count).by(-1)
    end
  end
end
