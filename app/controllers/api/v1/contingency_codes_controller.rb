# frozen_string_literal: true

module Api
  module V1
    class ContingencyCodesController < ApplicationController
      before_action :set_contingency_code, only: %i[show update destroy]
      before_action :set_economic_activity, only: %i[index create]

      def index
        @contingency_codes = @economic_activity.contingency_codes

        render json: @contingency_codes
      end

      def show
        render json: @contingency_code
      end

      def create
        @contingency_code = @economic_activity.contingency_codes.build(contingency_code_params)

        if @contingency_code.save
          render json: @contingency_code, status: :created
        else
          render json: @contingency_code.errors, status: :unprocessable_entity
        end
      end

      def update
        if @contingency_code.update(contingency_code_params)
          render json: @contingency_code
        else
          render json: @contingency_code.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @contingency_code.destroy
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_contingency_code
        @contingency_code = ContingencyCode.find(params[:id])
      end

      def set_economic_activity
        @economic_activity = EconomicActivity.find(params[:economic_activity_id])
      end

      # Only allow a list of trusted parameters through.
      def contingency_code_params
        params.require(:contingency_code).permit(:code, :limit, :document_sector_code)
      end
    end
  end
end
