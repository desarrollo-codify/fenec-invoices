# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/cycles', type: :request do
  before(:all) do
    @user = create(:user)
    @auth_headers = @user.create_new_auth_token
  end

  after(:all) do
    @user.destroy
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      cycle = create(:cycle)
      get api_v1_cycle_url(cycle), headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'PUT /update' do
    context 'with valid parameters' do
      let(:new_attributes) { { status: 'ABIERTA' } }

      it 'renders a JSON response with the api_v1_cycle' do
        cycle = create(:cycle)
        put api_v1_cycle_url(cycle),
            params: { cycle: new_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { status: nil } }

      it 'renders a JSON response with errors for the api_v1_cycle' do
        cycle = create(:cycle)
        put api_v1_cycle_url(cycle),
            params: { cycle: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested api_v1_cycle' do
      cycle = create(:cycle)
      expect do
        delete api_v1_cycle_url(cycle), headers: @auth_headers, as: :json
      end.to change(Cycle, :count).by(-1)
    end
  end
end
