# frozen_string_literal: true

module Api
  module V1
    class DocumentSectorsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_economic_activity

      def index
        @document_sectors = @economic_activity.document_sectors.all.order(:code)

        render json: @document_sectors
      end

      private

      def set_economic_activity
        @economic_activity = EconomicActivity.find(params[:economic_activity_id])
      end
    end
  end
end
