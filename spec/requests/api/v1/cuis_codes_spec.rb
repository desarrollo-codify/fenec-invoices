# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::CuisCodes', type: :request do
  describe 'GET /current' do
    before { create(:company) }

    it 'returns http success' do
      branch_office = BranchOffice.last
      create(:cuis_code, branch_office: branch_office)
      get '/api/v1/branch_offices/1/cuis_codes/current?point_of_sale=0'
      expect(response).to have_http_status(:success)
    end
  end
end
