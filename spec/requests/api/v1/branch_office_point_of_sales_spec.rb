# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/branch_offices/:branch_office_id/point_of_sales', type: :request do
  let(:valid_attributes) do
    {
      name: 'abc',
      code: 123
    }
  end

  let(:invalid_attributes) do
    {
      name: nil,
      code: nil
    }
  end

  let(:valid_headers) do
    {}
  end

  describe 'GET /index' do
    let(:branch_office) { create(:branch_office) }

    it 'renders a successful response' do
      create(:point_of_sale, branch_office: branch_office)
      get api_v1_branch_office_point_of_sales_url(branch_office_id: branch_office.id), headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    let(:branch_office) { create(:branch_office) }

    context 'with valid parameters' do
      it 'creates a new PointOfSale' do
        expect do
          post api_v1_branch_office_point_of_sales_url(branch_office_id: branch_office.id),
               params: { point_of_sale: valid_attributes }, headers: valid_headers, as: :json
        end.to change(PointOfSale, :count).by(1)
      end

      it 'renders a JSON response with the new api_v1_branch_office' do
        post api_v1_branch_office_point_of_sales_url(branch_office_id: branch_office.id),
             params: { point_of_sale: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new PointOfSale' do
        expect do
          post api_v1_branch_office_point_of_sales_url(branch_office_id: branch_office.id),
               params: { point_of_sale: invalid_attributes }, as: :json
        end.to change(PointOfSale, :count).by(0)
      end

      it 'renders a JSON response with errors for the new api_v1_company_branch_office' do
        post api_v1_branch_office_point_of_sales_url(branch_office_id: branch_office.id),
             params: { point_of_sale: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end
end