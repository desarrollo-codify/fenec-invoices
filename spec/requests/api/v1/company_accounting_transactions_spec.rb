# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'api/v1/accounting_transactions', type: :request do
  let(:valid_attributes) do
    {
      date: '01/01/2022',
      gloss: 'prueba 4',
      currency_id: 1,
      cycle_id: 1,
      transaction_type_id: 1,
      entries_attributes: [
        {
          debit_bs: 10,
          credit_bs: 0,
          debit_sus: 0,
          credit_sus: 0,
          account_id: 1
        },
        {
          debit_bs: 0,
          credit_bs: 10,
          debit_sus: 0,
          credit_sus: 0,
          account_id: 1
        }
      ]
    }
  end

  let(:invalid_attributes) do
    {
      date: nil,
      gloss: nil,
      currency_id: nil,
      cycle_id: nil,
      transaction_type_id: nil,
      entries_attributes: [
        {
          id: nil,
          debit_bs: 10,
          credit_bs: 0,
          debit_sus: 0,
          credit_sus: 0,
          account_id: 1
        },
        {
          id: nil,
          debit_bs: 0,
          credit_bs: 10,
          debit_sus: 0,
          credit_sus: 0,
          account_id: 1
        }
      ]
    }
  end

  before(:all) do
    @user = create(:user)
    @auth_headers = @user.create_new_auth_token
  end

  after(:all) do
    @user.destroy
  end

  before(:each) do
    @company = create(:company, name: 'Example')
    @currency = create(:currency)
    @cycle = create(:cycle, company: @company)
    @period = create(:period, cycle: @cycle)
    @transaction_type = create(:transaction_type)
    @account_type = create(:account_type)
    @account_level = create(:account_level)
    @account = create(:account, account_type: @account_type, account_level: @account_level, company: @company, cycle: @cycle)
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      accounting_transaction = build(:accounting_transaction, period: @period, company: @company)
      accounting_transaction.entries.build(debit_bs: 0, credit_bs: 6.96, debit_sus: 0, credit_sus: 1, account: @account)
      accounting_transaction.entries.build(debit_bs: 6.96, credit_bs: 0, debit_sus: 1, credit_sus: 0, account: @account)
      accounting_transaction.save
      get api_v1_company_accounting_transactions_url(@company), headers: @auth_headers, as: :json
      expect(response).to be_successful
      expect(@company.accounting_transactions.count).to eq(1)
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new AccountingTransaction' do
        expect do
          post api_v1_company_accounting_transactions_url(company_id: @company.id),
               params: { accounting_transaction: valid_attributes }, headers: @auth_headers, as: :json
        end.to change(AccountingTransaction, :count).by(1)
      end

      it 'renders a JSON response with the new accounting_transaction' do
        post api_v1_company_accounting_transactions_url(@company),
             params: { accounting_transaction: valid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new AccountingTransaction' do
        expect do
          post api_v1_company_accounting_transactions_url(@company),
               params: { accounting_transaction: invalid_attributes }, headers: @auth_headers, as: :json
        end.to change(AccountingTransaction, :count).by(0)
      end

      it 'renders a JSON response with errors for the new accounting_transaction' do
        post api_v1_company_accounting_transactions_url(@company),
             params: { accounting_transaction: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end
end
