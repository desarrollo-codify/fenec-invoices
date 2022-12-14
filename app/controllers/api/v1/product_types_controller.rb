# frozen_string_literal: true

module Api
  module V1
    class ProductTypesController < ApplicationController
      before_action :authenticate_user!
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
          render json: @product_type, status: :created
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

      def set_product_type
        @product_type = ProductType.find(params[:id])
      end

      def product_type_params
        params.require(:product_type).permit(:description)
      end
    end
  end
end
