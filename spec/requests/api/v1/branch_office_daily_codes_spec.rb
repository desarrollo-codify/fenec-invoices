# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/branch_offices/:branch_office_id/daily_codes', type: :request do
  let(:valid_attributes) do
    {
      code: '123',
      effective_date: '2022-01-01',
      control_code: '123',
      end_date: '2022-01-01'
    }
  end

  let(:invalid_attributes) do
    {
      code: nil,
      effective_date: nil,
      control_code: nil,
      end_date: nil
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
    let(:branch_office) { create(:branch_office) }

    it 'renders a successful response' do
      create(:daily_code, branch_office: branch_office)
      get api_v1_branch_office_daily_codes_url(branch_office_id: branch_office.id), headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    let(:branch_office) { create(:branch_office) }

    context 'with valid parameters' do
      it 'creates a new DailyCode' do
        expect do
          post api_v1_branch_office_daily_codes_url(branch_office_id: branch_office.id),
               params: { daily_code: valid_attributes }, headers: @auth_headers, as: :json
        end.to change(DailyCode, :count).by(1)
      end

      it 'renders a JSON response with the new api_v1_branch_office' do
        post api_v1_branch_office_daily_codes_url(branch_office_id: branch_office.id),
             params: { daily_code: valid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new DailyCode' do
        expect do
          post api_v1_branch_office_daily_codes_url(branch_office_id: branch_office.id),
               params: { daily_code: invalid_attributes }, headers: @auth_headers, as: :json
        end.to change(DailyCode, :count).by(0)
      end

      it 'renders a JSON response with errors for the new api_v1_company_branch_office' do
        post api_v1_branch_office_daily_codes_url(branch_office_id: branch_office.id),
             params: { daily_code: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end
end
