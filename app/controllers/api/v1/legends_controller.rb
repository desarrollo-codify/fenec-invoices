# frozen_string_literal: true

module Api
  module V1
    class LegendsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_economic_activity

      # GET /api/v1/legends
      def index
        @legends = @economic_activity.legends.all

        render json: @legends
      end

      private

      def set_economic_activity
        @economic_activity = EconomicActivity.find(params[:economic_activity_id])
      end
    end
  end
end
