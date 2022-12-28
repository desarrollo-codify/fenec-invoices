# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/product_types', type: :request do
  let(:valid_attributes) do
    skip('Add a hash of attributes valid for your model')
  end

  let(:invalid_attributes) do
    skip('Add a hash of attributes invalid for your model')
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
      ProductType.create! valid_attributes
      get api_v1_product_types_url, headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      product_type = ProductType.create! valid_attributes
      get api_v1_product_type_url(product_type), as: :json
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new ProductType' do
        expect do
          post api_v1_product_types_url,
               params: { api_v1_product_type: valid_attributes }, headers: @auth_headers, as: :json
        end.to change(ProductType, :count).by(1)
      end

      it 'renders a JSON response with the new api_v1_product_type' do
        post api_v1_product_types_url,
             params: { api_v1_product_type: valid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new ProductType' do
        expect do
          post api_v1_product_types_url,
               params: { api_v1_product_type: invalid_attributes }, as: :json
        end.to change(ProductType, :count).by(0)
      end

      it 'renders a JSON response with errors for the new api_v1_product_type' do
        post api_v1_product_types_url,
             params: { api_v1_product_type: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) do
        skip('Add a hash of attributes valid for your model')
      end

      it 'updates the requested api_v1_product_type' do
        product_type = ProductType.create! valid_attributes
        patch api_v1_product_type_url(product_type),
              params: { api_v1_product_type: new_attributes }, headers: @auth_headers, as: :json
        product_type.reload
        skip('Add assertions for updated state')
      end

      it 'renders a JSON response with the api_v1_product_type' do
        product_type = ProductType.create! valid_attributes
        patch api_v1_product_type_url(product_type),
              params: { api_v1_product_type: new_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'renders a JSON response with errors for the api_v1_product_type' do
        product_type = ProductType.create! valid_attributes
        patch api_v1_product_type_url(product_type),
              params: { api_v1_product_type: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested api_v1_product_type' do
      product_type = ProductType.create! valid_attributes
      expect do
        delete api_v1_product_type_url(product_type), headers: @auth_headers, as: :json
      end.to change(ProductType, :count).by(-1)
    end
  end
end
