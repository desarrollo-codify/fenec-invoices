# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Aromas', type: :request do
  describe 'GET /generate' do
    it 'returns http success' do
      get '/aromas/generate'
      expect(response).to have_http_status(:success)
    end
  end
end
