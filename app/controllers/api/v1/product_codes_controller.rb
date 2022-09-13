# frozen_string_literal: true

module Api
  module V1
    class ProductCodesController < ApplicationController
      before_action :set_economic_activity

      # GET /api/v1/economic_activities/1/product_codes
      def index
        @product_codes = @economic_activity.product_codes.all

        render json: @product_codes
      end

      private

      def set_economic_activity
        @economic_activity = EconomicActivity.find(params[:economic_activity_id])
      end
    end
  end
end
