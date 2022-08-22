# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::DocumentTypes', type: :request do
  let(:valid_headers) do
    {}
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:document_type)
      get api_v1_document_types_url, headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end
end