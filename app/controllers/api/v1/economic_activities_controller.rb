# frozen_string_literal: true

module Api
  module V1
    class EconomicActivitiesController < ApplicationController
      before_action :set_company, only: %i[index]

      # GET /api/v1/companies/:company_id/economic_activities
      def index
        @economic_activities = @company.economic_activities.all

        render json: @economic_activities
      end

      private

      def set_company
        @company = Company.find(params[:company_id])
      end
    end
  end
end
