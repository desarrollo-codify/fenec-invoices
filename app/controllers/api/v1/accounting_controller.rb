# frozen_string_literal: true

module Api
  module V1
    class AccountingController < ApplicationController
      before_action :authenticate_user!

      def currencies
        @currencies = Currency.all
        render json: @currencies
      end

      def transaction_types
        @transaction_types = TransactionType.all
        render json: @transaction_types
      end
    end
  end
end
