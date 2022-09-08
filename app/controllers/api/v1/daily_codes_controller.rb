# frozen_string_literal: true

module Api
  module V1
    class DailyCodesController < ApplicationController
      before_action :set_daily_code, only: %i[show update destroy]
      before_action :set_branch_office, only: %i[index create]

      # GET /api/v1/branch_offices/:branch_office_id/daily_codes
      def index
        @daily_codes = @branch_office.daily_codes

        render json: @daily_codes
      end

      # GET /api/v1/daily_codes/1
      def show
        render json: @daily_code
      end

      # POST /api/v1/branch_offices/:branch_office_id/daily_codes
      def create
        @daily_code = @branch_office.daily_codes.build(daily_code_params)

        if @daily_code.save
          render json: @daily_code, status: :created
        else
          render json: @daily_code.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/daily_codes/1
      def update
        if @daily_code.update(daily_code_params)
          render json: @daily_code
        else
          render json: @daily_code.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/daily_codes/1
      def destroy
        @daily_code.destroy
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_daily_code
        @daily_code = DailyCode.find(params[:id])
      end

      def set_branch_office
        @branch_office = BranchOffice.find(params[:branch_office_id])
      end

      # Only allow a list of trusted parameters through.
      def daily_code_params
        params.require(:daily_code).permit(:code, :effective_date, :control_code, :end_date)
      end
    end
  end
end
