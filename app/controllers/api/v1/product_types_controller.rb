# frozen_string_literal: true

module Api
  module V1
    class ProductTypesController < ApplicationController
      before_action :set_product_type, only: %i[show update destroy]

      # GET /api/v1/product_types
      def index
        @product_types = ProductType.all

        render json: @product_types
      end

      # GET /api/v1/product_types/1
      def show
        render json: @product_type
      end

      # POST /api/v1/product_types
      def create
        @product_type = ProductType.new(product_type_params)

        if @product_type.save
          render json: @product_type, status: :created, location: @product_type
        else
          render json: @product_type.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/product_types/1
      def update
        if @product_type.update(product_type_params)
          render json: @product_type
        else
          render json: @product_type.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/product_types/1
      def destroy
        @product_type.destroy
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_product_type
        @product_type = ProductType.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def product_type_params
        params.fetch(:product_type, {})
      end
    end
  end
end
