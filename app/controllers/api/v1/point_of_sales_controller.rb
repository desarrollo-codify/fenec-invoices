# frozen_string_literal: true

module Api
  module V1
    class PointOfSalesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_point_of_sale, only: %i[show update destroy]
      before_action :set_branch_office, only: %i[index create]
      require 'point_of_sale'

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
        transaction = PointOfSale.add(@point_of_sale)
        if transaction && @point_of_sale.save
          render json: @point_of_sale, status: :created
        else
          return render json: @point_of_sale.errors, status: :unprocessable_entity if transaction

          render json: { message: 'No se pudo crear el punto de venta en el SIAT, verifique sus datos e intente nuevamente.' },
                 status: :unprocessable_entity
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
        transaction = PointOfSale.destroy(@point_of_sale)
        if transaction
          @point_of_sale.destroy
          render json: { message: "Se ha eliminado correctamente el punto de venta #{@point_of_sale.code}." }, status: :no_content
        else
          render json: { message: 'No se ha podido eliminar el punto de venta, verifique sus datos e intente nuevamente.' },
                 status: :unprocessable_entity
        end
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
        params.require(:point_of_sale).permit(:name, :description, :branch_office_id, :pos_type_id)
      end
    end
  end
end
