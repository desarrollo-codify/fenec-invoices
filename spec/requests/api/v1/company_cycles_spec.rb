# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/companies/:company_id/cycles', type: :request do
  let(:valid_attributes) do
    {
      year: 2023,
      start_date: '01-01-2023',
      end_date: '31-12-2023',
      status: 'ABIERTA'
    }
  end

  let(:invalid_attributes) do
    {
      year: nil,
      start_date: nil,
      end_date: nil,
      status: nil
    }
  end

  before(:all) do
    @user = create(:user)
    @auth_headers = @user.create_new_auth_token
  end

  after(:all) do
    @user.destroy
  end

  describe 'GET /index' do
    let(:company) { create(:company) }
    it 'renders a successful response' do
      create(:cycle, company: company)
      get api_v1_company_cycles_url(company), headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      let(:company) { create(:company) }
      it 'creates a new Api::V1::Cycle' do
        expect do
          post api_v1_company_cycles_url(company),
               params: { cycle: valid_attributes }, headers: @auth_headers, as: :json
        end.to change(Cycle, :count).by(1)
      end

      it 'renders a JSON response with the new api_v1_cycle' do
        post api_v1_company_cycles_url(company),
             params: { cycle: valid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      let(:company) { create(:company) }
      it 'does not create a new Api::V1::Cycle' do
        expect do
          post api_v1_company_cycles_url(company),
               params: { cycle: invalid_attributes }, as: :json
        end.to change(Cycle, :count).by(0)
      end

      it 'renders a JSON response with errors for the new api_v1_cycle' do
        post api_v1_company_cycles_url(company),
             params: { cycle: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end
end
