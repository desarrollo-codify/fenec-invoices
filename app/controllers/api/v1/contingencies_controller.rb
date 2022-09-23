# frozen_string_literal: true

module Api
  module V1
    class ContingenciesController < ApplicationController
      before_action :set_contingency, only: %i[show close update destroy]
      before_action :set_point_of_sale, only: %i[index create]
      # GET /api/v1/contingencies
      def index
        @contingencies = @point_of_sale.contingencies.includes(:significative_event)

        render json: @contingencies.as_json(include: [
          { significative_event: { except: %i[created_at updated_at] } },
          { point_of_sale: { except: %i[created_at updated_at] } },
        ])
      end

      # GET /api/v1/contingencies/1
      def show
        render json: @contingency
      end

      # POST /api/v1/branch_office/:branch_office_id/contingencies
      def create
        @contingency = @point_of_sale.contingencies.build(contingency_params)
        @contingency.start_date = DateTime.now
        @contingency.cufd_code = DailyCode.where(point_of_sale: params[:point_of_sale_id]).last.code

        if @contingency.save
          render json: @contingency, status: :created
        else
          render json: @contingency.errors, status: :unprocessable_entity
        end
      end

      # POST api/v1/contingencies/:contingency_id/close
      def close
        CloseContingencyJob.perform_later(@contingency)
        SendCancelInvoicesJob.perform_later
        render json: @contingency, status: :created
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

      def set_point_of_sale
        @point_of_sale = PointOfSale.find(params[:point_of_sale_id])
      end

      # Only allow a list of trusted parameters through.
      def contingency_params
        params.require(:contingency).permit(:start_date, :end_date, :significative_event_id)
      end
    end
  end
end
