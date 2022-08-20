# frozen_string_literal: true

module Api
  module V1
    class PaymentMethodsController < ApplicationController
      # GET /api/v1/payment_methods
      def index
        @payment_methods = PaymentMethod.all

        render json: @payment_methods
      end
    end
  end
end
