# frozen_string_literal: true

module Api
  module V1
    class PointOfSalesController < ApplicationController
      before_action :set_point_of_sale, only: %i[show update destroy]
      before_action :set_branch_office, only: %i[index create]

      # GET /api/v1/branch_offices/:branch_office_id/point_of_sales
      def index
        @point_of_sales = @branch_office.point_of_sales

        render json: @point_of_sales
      end

      # GET /api/v1/point_of_sales/1
      def show
        render json: @point_of_sale
      end

      # POST /api/v1/branch_offices/:branch_office_id/point_of_sales
      def create
        @point_of_sale = @branch_office.point_of_sales.build(point_of_sale_params)

        if @point_of_sale.save
          PointOfSaleJob.perform_now(@point_of_sale) if Rails.env.development? || Rails.env.production?
          render json: @point_of_sale, status: :created
        else
          render json: @point_of_sale.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/point_of_sales/1
      def update
        if @point_of_sale.update(point_of_sale_params)
          render json: @point_of_sale
        else
          render json: @point_of_sale.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/point_of_sales/1
      def destroy
        @point_of_sale.destroy
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_point_of_sale
        @point_of_sale = PointOfSale.find(params[:id])
      end

      def set_branch_office
        @branch_office = BranchOffice.find(params[:branch_office_id])
      end

      # Only allow a list of trusted parameters through.
      def point_of_sale_params
        params.require(:point_of_sale).permit(:name, :code, :description, :branch_office_id)
      end
    end
  end
end
