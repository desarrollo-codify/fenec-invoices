# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Periods', type: :request do
  let(:valid_attributes) do
    {
      description: 'Enero-2023',
      start_date: '01-01-2023',
      end_date: '31-01-2023',
      status: 'ABIERTA'
    }
  end

  let(:invalid_attributes) do
    {
      description: nil,
      start_date: '01-01-2023',
      end_date: '31-01-2023',
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
    let(:cycle) { create(:cycle) }
    it 'renders a successful response' do
      create(:period, cycle: cycle)
      get api_v1_cycle_periods_url(cycle), headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      let(:cycle) { create(:cycle) }
      it 'creates a new Api::V1::Cycle' do
        expect do
          post api_v1_cycle_periods_url(cycle),
               params: { period: valid_attributes }, headers: @auth_headers, as: :json
        end.to change(Period, :count).by(1)
      end

      it 'renders a JSON response with the new api_v1_cycle' do
        post api_v1_cycle_periods_url(cycle),
             params: { period: valid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      let(:cycle) { create(:cycle) }
      it 'does not create a new Api::V1::Cycle' do
        expect do
          post api_v1_cycle_periods_url(cycle),
               params: { period: invalid_attributes }, as: :json
        end.to change(Period, :count).by(0)
      end

      it 'renders a JSON response with errors for the new api_v1_cycle' do
        post api_v1_cycle_periods_url(cycle),
             params: { period: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'when there is already an open period' do
      let(:cycle) { create(:cycle) }
      before { create(:period, cycle: cycle) }

      it 'does not create a new Api::V1::Cycle' do
        expect do
          post api_v1_cycle_periods_url(cycle),
               params: { period: valid_attributes }, headers: @auth_headers, as: :json
        end.to change(Period, :count).by(0)
      end
    end

    context 'When the start date is earlier than the end date' do
      let(:cycle) { create(:cycle) }

      let(:attributes) do
        {
          description: 'Enero-2023',
          start_date: '02-01-2023',
          end_date: '01-01-2023',
          status: 'ABIERTA'
        }
      end
      it 'does not create a new Api::V1::Cycle' do
        expect do
          post api_v1_cycle_periods_url(cycle),
               params: { period: attributes }, headers: @auth_headers, as: :json
        end.to change(Period, :count).by(0)
      end
    end

    context 'When the start date falls within the time period of any other period in the same management' do
      let(:cycle) { create(:cycle) }
      before { create(:period, cycle: cycle, start_date: '01-12-2022', end_date: '31-12-2022', status: 'CERRADO') }

      let(:attributes) do
        {
          description: 'Enero-2023',
          start_date: '31-12-2022',
          end_date: '30-01-2023',
          status: 'ABIERTA'
        }
      end
      it 'does not create a new Api::V1::Cycle' do
        expect do
          post api_v1_cycle_periods_url(cycle),
               params: { period: attributes }, headers: @auth_headers, as: :json
        end.to change(Period, :count).by(0)
      end
    end
  end
end
