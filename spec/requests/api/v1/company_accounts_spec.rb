# frozen_string_literal: true

require 'rails_helper'
require 'csv'

RSpec.describe '/api/v1/companies/:company_id/accounts', type: :request do
  let(:valid_attributes) do
    {
      number: '123',
      description: 'abc',
      amount: 120,
      percentage: 10,
      cycle_id: 1,
      account_level_id: 1,
      account_type_id: 1
    }
  end

  let(:invalid_attributes) do
    {
      number: nil,
      description: nil
    }
  end

  before(:all) do
    @user = create(:user)
    @auth_headers = @user.create_new_auth_token
  end
  
  after(:all) do
    @user.destroy  
  end

  let(:data) do
    CSV.generate do |csv|
      csv << %w[number description level]
      csv << %w[10000 abc 1]
      csv << %w[20000 def 2]
    end
  end

  let(:header) { 'number, description, level' }
  let(:row2) { 'value1, value2, value3' }
  let(:row3) { 'value1, value2, value3' }
  let(:rows) { [header, row2, row3] }

  let(:file_path) { 'spec/fixtures/csv_example.csv' }
  let!(:csv) do
    CSV.open(file_path, 'w') do |csv|
      rows.each do |row|
        csv << row.split(',')
      end
    end
  end

  let(:csv_file) { Csv::InventoryItemProcessor.new(file_path) }

  describe 'GET /index' do
    let(:company) { create(:company) }
    let(:cycle) { create(:cycle, company: company) }
    let(:account_type) { create(:account_type) }
    let(:account_level) { create(:account_level) }
    before { create(:account, company: company, cycle: cycle, account_type: account_type, account_level: account_level) }
    it 'renders a successful response' do
      get api_v1_company_accounts_url(company_id: company.id), headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    before { @company = create(:company) }
    before { create(:cycle, company: @company) }
    before { create(:account_type) }
    before { create(:account_level) }
    context 'with valid parameters' do
      it 'creates a new Account' do
        expect do
          post api_v1_company_accounts_url(company_id: @company.id),
               params: { account: valid_attributes }, headers: @auth_headers, as: :json
        end.to change(Account, :count).by(1)
      end

      it 'renders a JSON response with the new api_v1_account' do
        post api_v1_company_accounts_url(company_id: @company.id),
             params: { account: valid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Account' do
        expect do
          post api_v1_company_accounts_url(company_id: @company.id),
               params: { account: invalid_attributes }, as: :json
        end.to change(Account, :count).by(0)
      end

      it 'renders a JSON response with errors for the new api_v1_account' do
        post api_v1_company_accounts_url(company_id: @company.id),
             params: { account: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  # describe 'POST /import' do
  #   # after(:each) { File.delete(file_path) }
  #   context 'with valid parameters' do
  #     before{ @company = create(:company) }
  #     before{ create(:cycle, company: @company) }
  #     before{ create(:account_type) }
  #     before{ create(:account_level) }
  #     it 'renders a successful response' do
  #       expect do
  #         post import_api_v1_company_accounts_url(company_id: @company.id),
  #              params: { csv: csv_file }, headers: @auth_headers, as: :json
  #       end.to change(Account, :count).by(2)
  #     end
  #   end
  # end
end
