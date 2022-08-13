# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::CompaniesController, type: :controller do
  describe 'GET #index' do
    # TODO: context 'with authenticated user'
    let(:perform_index) { get :index, as: :json }

    it 'returns a 200' do
      perform_index
      expect(response).to have_http_status(:ok)
    end
  end
end