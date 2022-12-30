# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/accounts', type: :request do
  let(:valid_attributes) do
    {}
  end

  let(:valid_headers) do
    {}
  end

  before(:all) do
    @user = create(:user)
    @auth_headers = @user.create_new_auth_token
  end

  after(:all) do
    @user.destroy
  end

  describe 'GET /show' do
    let(:company) { create(:company) }
    let(:cycle) { create(:cycle, company: company) }
    let(:account_type) { create(:account_type) }
    let(:account_level) { create(:account_level) }
    let(:account) { create(:account, company: company, cycle: cycle, account_type: account_type, account_level: account_level) }
    it 'renders a successful response' do
      get api_v1_account_url(account), headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) { { description: 'efg' } }
      let(:company) { create(:company) }
      let(:cycle) { create(:cycle, company: company) }
      let(:account_type) { create(:account_type) }
      let(:account_level) { create(:account_level) }
      let(:account) { create(:account, company: company, cycle: cycle, account_type: account_type, account_level: account_level) }

      it 'updates the requested api_v1_account' do
        put api_v1_account_url(account),
            params: { account: new_attributes }, headers: @auth_headers, as: :json
        account.reload
        expect(account.description).to eq('efg')
      end

      it 'renders a JSON response with the api_v1_account' do
        patch api_v1_account_url(account),
              params: { account: new_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { number: nil } }
      let(:company) { create(:company) }
      let(:cycle) { create(:cycle, company: company) }
      let(:account_type) { create(:account_type) }
      let(:account_level) { create(:account_level) }
      let(:account) { create(:account, company: company, cycle: cycle, account_type: account_type, account_level: account_level) }

      it 'renders a JSON response with errors for the api_v1_account' do
        put api_v1_account_url(account),
            params: { account: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end
end
