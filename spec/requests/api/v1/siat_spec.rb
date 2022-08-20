# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Siats', type: :request do
  # describe 'POST /generate_cuis' do
  #   let(:branch_office) { create(:branch_office) }

  #   it 'returns http success' do
  #     post api_v1_branch_office_siat_generate_cuis_url(branch_office_id: branch_office.id)
  #     expect(response).to have_http_status(:success)
  #   end
  # end

  describe 'GET /show_cuis' do
    let(:branch_office) { create(:branch_office) }
    before { create(:cuis_code, branch_office: branch_office) }

    it 'returns http success' do
      get api_v1_branch_office_siat_show_cuis_url(branch_office_id: branch_office.id)
      expect(response).to have_http_status(:success)
    end
  end

  # describe 'POST /generate_cufd' do
  #   let(:branch_office) { create(:branch_office) }

  #   it 'returns http success' do
  #     post api_v1_branch_office_siat_generate_cufd_url(branch_office_id: branch_office.id)
  #     expect(response).to have_http_status(:success)
  #   end
  # end

  describe 'GET /show_cufd' do
    let(:branch_office) { create(:branch_office) }
    before { create(:daily_code, branch_office: branch_office) }

    it 'returns http success' do
      get api_v1_branch_office_siat_show_cufd_url(branch_office_id: branch_office.id)
      expect(response).to have_http_status(:success)
    end
  end

  # describe 'POST /siat_product_codes' do
  #   it 'returns http success' do
  #     get '/api/v1/siat/siat_codes'
  #     expect(response).to have_http_status(:success)
  #   end
  # end

  # describe 'GET /bulk_products_update' do
  #   it 'returns http success' do
  #     get '/api/v1/siat/bulk_products_update'
  #     expect(response).to have_http_status(:success)
  #   end
  # end
end
