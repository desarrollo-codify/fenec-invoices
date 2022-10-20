# frozen_string_literal: true

module Api
  module V1
    class ProductsController < ApplicationController
      before_action :set_product, only: %i[show update destroy]
      before_action :set_company, only: %i[index create homologate]

      # GET /api/v1/companies/:company_id/products
      def index
        @products = @company.products.order(:primary_code)
        render json: @products
      end

      # GET /api/v1/products/1
      def show
        render json: @product
      end

      # POST /api/v1/companies/:company_id/products
      def create
        @product = @company.products.build(product_params)

        if @product.save
          render json: @product, status: :created
        else
          render json: @product.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/products/1
      def update
        if @product.update(product_params)
          render json: @product
        else
          render json: @product.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/products/1
      def destroy
        @product.destroy
      end

      # POST /api/v1/companies/:company_id/products/homologate
      def homologate
        product_ids = homologate_product_params[:product_ids]
        if @company.products.where(id: product_ids).update(sin_code: homologate_product_params[:sin_code])
          render json: product_ids
        else
          render json: { message: 'No fue posible homologar los productos' }, status: :unprocessable_entity
        end
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_product
        @product = Product.find(params[:id])
      end

      def set_company
        @company = Company.find(params[:company_id])
      end

      # Only allow a list of trusted parameters through.
      def product_params
        params.require(:product).permit(:primary_code, :description, :sin_code, :price)
      end

      def homologate_product_params
        params.require(:homologation).permit(:sin_code, product_ids: [])
      end
    end
  end
end
