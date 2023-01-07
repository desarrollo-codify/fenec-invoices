# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'api/v1/accounting_transactions', type: :request do
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
    @transaction_type = create(:transaction_type)
    @account_type = create(:account_type)
    @account_level = create(:account_level)
    @account = create(:account, account_type: @account_type, account_level: @account_level, company: @company, cycle: @cycle)
  end

  describe 'GET /show' do
    let(:company) { create(:company) }
    let(:cycle) { create(:cycle, company: company) }
    let(:account) { create(:account, cycle: cycle, company: company) }
    let(:account2) { create(:account, cycle: cycle, company: company) }
    let(:accounting_transaction) { build(:accounting_transaction, cycle: cycle, company: cycle.company) }

    it 'renders a successful response' do
      accounting_transaction.entries.build(debit_bs: 0, credit_bs: 6.96, debit_sus: 0, credit_sus: 1, account: account)
      accounting_transaction.entries.build(debit_bs: 6.96, credit_bs: 0, debit_sus: 1, credit_sus: 0, account: account2)
      accounting_transaction.save
      get api_v1_accounting_transaction_url(accounting_transaction), headers: @auth_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) do
        {
          date: '01/01/2022',
          gloss: 'prueba 4',
          currency_id: 1,
          cycle_id: 1,
          transaction_type_id: 1,
          entries_attributes: [
            {
              id: 1,
              debit_bs: 10,
              credit_bs: 0,
              debit_sus: 0,
              credit_sus: 0,
              account_id: 1
            },
            {
              id: 2,
              debit_bs: 0,
              credit_bs: 10,
              debit_sus: 0,
              credit_sus: 0,
              account_id: 1
            }
          ]
        }
      end

      it 'updates the requested accounting_transaction' do
        accounting_transaction = build(:accounting_transaction, company: @company, currency: @currency, cycle: @cycle,
                                                                transaction_type: @transaction_type)
        accounting_transaction.entries.build(debit_bs: 10, account: @account)
        accounting_transaction.entries.build(credit_bs: 10, account: @account)
        accounting_transaction.save
        put api_v1_accounting_transaction_url(accounting_transaction),
            params: { accounting_transaction: new_attributes }, headers: @auth_headers, as: :json
        accounting_transaction.reload
        expect(accounting_transaction.gloss).to eq('prueba 4')
      end

      it 'renders a JSON response with the accounting_transaction' do
        accounting_transaction = build(:accounting_transaction, company: @company, currency: @currency, cycle: @cycle,
                                                                transaction_type: @transaction_type)
        accounting_transaction.entries.build(debit_bs: 10, account: @account)
        accounting_transaction.entries.build(credit_bs: 10, account: @account)
        accounting_transaction.save
        put api_v1_accounting_transaction_url(accounting_transaction),
            params: { accounting_transaction: new_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'renders a JSON response with errors for the accounting_transaction' do
        accounting_transaction = build(:accounting_transaction, company: @company, currency: @currency, cycle: @cycle,
                                                                transaction_type: @transaction_type)
        accounting_transaction.entries.build(debit_bs: 10, account: @account)
        accounting_transaction.entries.build(credit_bs: 10, account: @account)
        accounting_transaction.save
        put api_v1_accounting_transaction_url(accounting_transaction),
            params: { accounting_transaction: invalid_attributes }, headers: @auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with valid parameters' do
      let(:new_attributes) do
        {
          date: '01/01/2022',
          gloss: 'prueba 4',
          currency_id: 1,
          cycle_id: 1,
          transaction_type_id: 1,
          entries_attributes: [
            {
              id: 1,
              debit_bs: 10,
              credit_bs: 0,
              debit_sus: 0,
              credit_sus: 0,
              account_id: 1
            },
            {
              id: 2,
              debit_bs: 0,
              credit_bs: 10,
              debit_sus: 0,
              credit_sus: 0,
              account_id: 1
            }
          ]
        }
      end

      it 'update with accounting_transaction is canceled' do
        accounting_transaction = build(:accounting_transaction, company: @company, currency: @currency, cycle: @cycle,
                                                                transaction_type: @transaction_type, status: 2)
        accounting_transaction.entries.build(debit_bs: 10, account: @account)
        accounting_transaction.entries.build(credit_bs: 10, account: @account)
        accounting_transaction.save
        put api_v1_accounting_transaction_url(accounting_transaction),
            params: { accounting_transaction: new_attributes }, headers: @auth_headers, as: :json
        accounting_transaction.reload
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to eq('["No se puede editar un comprobante anulado."]')
      end
    end
  end

  describe 'POST /cancel' do
    context 'with valid parameters' do
      it 'canceled accouting transactions' do
        accounting_transaction = build(:accounting_transaction, company: @company, currency: @currency, cycle: @cycle,
                                                                transaction_type: @transaction_type)
        accounting_transaction.entries.build(debit_bs: 10, account: @account)
        accounting_transaction.entries.build(credit_bs: 10, account: @account)
        accounting_transaction.save

        post cancel_api_v1_accounting_transaction_url(accounting_transaction), params: { reason: 'Reason 01' }, headers: @auth_headers, as: :json
        accounting_transaction.reload
        expect(accounting_transaction.status).to eq('canceled')
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'canceled accouting transactions' do
        accounting_transaction = build(:accounting_transaction, company: @company, currency: @currency, cycle: @cycle,
                                                                transaction_type: @transaction_type)
        accounting_transaction.entries.build(debit_bs: 10, account: @account)
        accounting_transaction.entries.build(credit_bs: 10, account: @account)
        accounting_transaction.save

        post cancel_api_v1_accounting_transaction_url(accounting_transaction), headers: @auth_headers, as: :json
        accounting_transaction.reload
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when accouting transactions is already canceled' do
      it 'canceled accouting transactions' do
        accounting_transaction = build(:accounting_transaction, company: @company, currency: @currency, cycle: @cycle,
                                                                transaction_type: @transaction_type)
        accounting_transaction.entries.build(debit_bs: 10, account: @account)
        accounting_transaction.entries.build(credit_bs: 10, account: @account)
        accounting_transaction.save

        post cancel_api_v1_accounting_transaction_url(accounting_transaction), headers: @auth_headers, as: :json
        accounting_transaction.reload
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
