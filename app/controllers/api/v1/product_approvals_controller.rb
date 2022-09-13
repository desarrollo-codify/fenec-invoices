# frozen_string_literal: true

module Api
  module V1
    class ProductApprovalsController < ApplicationController
      before_action :set_economic_activity

      def index
        @product_approvals = @economic_activity.product_approvals.all.order(:code)

        render json: @product_approvals
      end

      private

      def set_economic_activity
        @economic_activity = EconomicActivity.find(params[:economic_activity_id])
      end
    end
  end
end
