# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/products', type: :request do
  let(:invalid_attributes) do
    {
      primary_code: nil,
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
    let(:product) { create(:product) }

    it 'renders a successful response' do
      get api_v1_product_url(product), headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'PUT /update' do
    context 'with valid parameters' do
      let(:new_attributes) { { description: 'xyz' } }
      let(:product) { create(:product) }

      it 'updates the requested product' do
        put api_v1_product_url(product),
            params: { product: new_attributes }, headers: @auth_headers, as: :json
        product.reload
        expect(product.description).to eq('xyz')
      end

      it 'renders a JSON response with the product' do
        put api_v1_product_url(product),
            params: { product: new_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      let(:product) { create(:product) }

      it 'renders a JSON response with errors for the product' do
        put api_v1_product_url(product),
            params: { product: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested product' do
      product = create(:product)
      expect do
        delete api_v1_product_url(product), headers: @auth_headers, as: :json
      end.to change(Product, :count).by(-1)
    end
  end
end
