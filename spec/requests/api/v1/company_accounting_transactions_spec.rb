# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'api/v1/accounting_transactions', type: :request do
  #   let(:valid_attributes) do
  #     skip('Add a hash of attributes valid for your model')
  #   end

  #   let(:invalid_attributes) do
  #     skip('Add a hash of attributes invalid for your model')
  #   end

  #   let(:valid_headers) do
  #     {}
  #   end

  #   describe 'GET /index' do
  #     it 'renders a successful response' do
  #       AccountingTransaction.create! valid_attributes
  #       get accounting_transactions_url, headers: valid_headers, as: :json
  #       expect(response).to be_successful
  #     end
  #   end

  #   describe 'POST /create' do
  #     context 'with valid parameters' do
  #       it 'creates a new AccountingTransaction' do
  #         expect do
  #           post accounting_transactions_url,
  #                params: { accounting_transaction: valid_attributes }, headers: valid_headers, as: :json
  #         end.to change(AccountingTransaction, :count).by(1)
  #       end

  #       it 'renders a JSON response with the new accounting_transaction' do
  #         post accounting_transactions_url,
  #              params: { accounting_transaction: valid_attributes }, headers: valid_headers, as: :json
  #         expect(response).to have_http_status(:created)
  #         expect(response.content_type).to match(a_string_including('application/json'))
  #       end
  #     end

  #     context 'with invalid parameters' do
  #       it 'does not create a new AccountingTransaction' do
  #         expect do
  #           post accounting_transactions_url,
  #                params: { accounting_transaction: invalid_attributes }, as: :json
  #         end.to change(AccountingTransaction, :count).by(0)
  #       end

  #       it 'renders a JSON response with errors for the new accounting_transaction' do
  #         post accounting_transactions_url,
  #              params: { accounting_transaction: invalid_attributes }, headers: valid_headers, as: :json
  #         expect(response).to have_http_status(:unprocessable_entity)
  #         expect(response.content_type).to match(a_string_including('application/json'))
  #       end
  #     end
  #   end
end
