# frozen_string_literal: true

module Api
  module V1
    class ContingenciesController < ApplicationController
      before_action :set_contingency, only: %i[show update destroy]
      before_action :set_branch_office, only: %i[index create]
      # GET /api/v1/contingencies
      def index
        @contingencies = branch_office.contingencies

        render json: @contingencies
      end

      # GET /api/v1/contingencies/1
      def show
        render json: @contingency
      end

      # POST /api/v1/branch_office/:branch_office_id/contingencies
      def create
        @contingency = @branch_office.contingencies.build(contingency_params)

        if @contingency.save
          render json: @contingency, status: :created
        else
          render json: @contingency.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/contingencies/1
      def update
        if @contingency.update(contingency_params)
          render json: @contingency
        else
          render json: @contingency.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/contingencies/1
      def destroy
        @contingency.destroy
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_contingency
        @contingency = Contingency.find(params[:id])
      end

      def set_branch_office
        @branch_office = BranchOffice.find(params[:branch_office_id])
      end

      # Only allow a list of trusted parameters through.
      def contingency_params
        params.require(:contingency).permit(:start_date, :end_date, :significative_event_id)
      end
    end
  end
end