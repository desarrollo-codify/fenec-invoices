# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/point_of_sales', type: :request do
  let(:invalid_attributes) do
    {
      number: nil,
      name: nil,
      code: nil
    }
  end

  let(:valid_headers) do
    {}
  end

  describe 'GET /show' do
    let(:point_of_sale) { create(:point_of_sale) }

    it 'renders a successful response' do
      get api_v1_point_of_sale_url(point_of_sale), as: :json
      expect(response).to be_successful
    end
  end

  describe 'PUT /update' do
    context 'with valid parameters' do
      let(:new_attributes) { { description: 'xyz' } }
      let(:point_of_sale) { create(:point_of_sale) }

      it 'updates the requested point_of_sale' do
        put api_v1_point_of_sale_url(point_of_sale),
            params: { point_of_sale: new_attributes }, headers: valid_headers, as: :json
        point_of_sale.reload
        skip('Add assertions for updated state')
      end

      it 'renders a JSON response with the point_of_sale' do
        put api_v1_point_of_sale_url(point_of_sale),
            params: { point_of_sale: new_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      let(:point_of_sale) { create(:point_of_sale) }

      it 'renders a JSON response with errors for the point_of_sale' do
        put api_v1_point_of_sale_url(point_of_sale),
            params: { point_of_sale: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested point_of_sale' do
      point_of_sale = create(:point_of_sale)
      expect do
        delete api_v1_point_of_sale_url(point_of_sale), headers: valid_headers, as: :json
      end.to change(PointOfSale, :count).by(-1)
    end
  end
end
