class Api::V1::CancellationReasonsController < ApplicationController
  # GET /api/v1/cancellation_reasons
  def index
    @cancellation_reasons = CancellationReason.all

    render json: @cancellation_reasons
  end
end
