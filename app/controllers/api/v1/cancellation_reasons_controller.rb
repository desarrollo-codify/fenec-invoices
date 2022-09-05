# frozen_string_literal: true

module Api
  module V1
    class CancellationReasonsController < ApplicationController
      # GET /api/v1/cancellation_reasons
      def index
        @cancellation_reasons = CancellationReason.all

        render json: @cancellation_reasons
      end
    end
  end
end
