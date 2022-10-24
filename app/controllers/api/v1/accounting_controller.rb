class Api::V1::AccountingController < ApplicationController
  def currencies
    @currencies = Currency.all
    render json: @currencies
  end

  def transaction_types
    @transaction_types = TransactionType.all
    render json: @transaction_types
  end
end
