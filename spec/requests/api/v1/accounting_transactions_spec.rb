# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'api/v1/accounting_transactions', type: :request do
  let(:valid_attributes) do
    skip('Add a hash of attributes valid for your model')
  end

  let(:invalid_attributes) do
    skip('Add a hash of attributes invalid for your model')
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

  # describe 'PATCH /update' do
  #   context 'with valid parameters' do
  #     let(:new_attributes) do
  #       skip('Add a hash of attributes valid for your model')
  #     end

  #     it 'updates the requested accounting_transaction' do
  #       accounting_transaction = AccountingTransaction.create! valid_attributes
  #       patch accounting_transaction_url(accounting_transaction),
  #             params: { accounting_transaction: new_attributes }, headers: valid_headers, as: :json
  #       accounting_transaction.reload
  #       skip('Add assertions for updated state')
  #     end

  #     it 'renders a JSON response with the accounting_transaction' do
  #       accounting_transaction = AccountingTransaction.create! valid_attributes
  #       patch accounting_transaction_url(accounting_transaction),
  #             params: { accounting_transaction: new_attributes }, headers: valid_headers, as: :json
  #       expect(response).to have_http_status(:ok)
  #       expect(response.content_type).to match(a_string_including('application/json'))
  #     end
  #   end

  #   context 'with invalid parameters' do
  #     it 'renders a JSON response with errors for the accounting_transaction' do
  #       accounting_transaction = AccountingTransaction.create! valid_attributes
  #       patch accounting_transaction_url(accounting_transaction),
  #             params: { accounting_transaction: invalid_attributes }, headers: valid_headers, as: :json
  #       expect(response).to have_http_status(:unprocessable_entity)
  #       expect(response.content_type).to match(a_string_including('application/json'))
  #     end
  #   end
  # end

  # describe 'DELETE /destroy' do
  #   it 'destroys the requested accounting_transaction' do
  #     accounting_transaction = AccountingTransaction.create! valid_attributes
  #     expect do
  #       delete accounting_transaction_url(accounting_transaction), headers: valid_headers, as: :json
  #     end.to change(AccountingTransaction, :count).by(-1)
  #   end
  # end
end
