# frozen_string_literal: true

require 'csv'

module Api
  module V1
    class ProductsController < ApplicationController
      before_action :set_product, only: %i[show update destroy]
      before_action :set_company, only: %i[index create homologate import]

      # GET /api/v1/companies/:company_id/products
      def index
        @products = @company.products.includes(:brand, :product_type, :variants).order(:primary_code)
        render json: @products.as_json(except: %i[created_at updated_at],
          include: [
            { brand: { only: :description } },
            { product_type: { only: :description } },
            { variants: { except: %i[created_at updated_at] } }
          ])
      end

      # GET /api/v1/products/1
      def show
        render json: @product.as_json(except: %i[created_at updated_at],
          include: [
            { brand: { only: :description } },
            { product_type: { only: :description } },
            { variants: { except: %i[created_at updated_at] } }
          ])
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

      # POST /api/v1/companies/1/products/homologate
      def homologate
        product_ids = homologate_product_params[:product_ids]
        if @company.products.where(id: product_ids).update(sin_code: homologate_product_params[:sin_code])
          render json: product_ids
        else
          render json: { message: 'No fue posible homologar los productos' }, status: :unprocessable_entity
        end
      end

      #POST /api/v1/companies/1/products/import
      def import
        if import_params[:csv].content_type.include?('csv')
          csv_text = File.read(import_params[:csv].tempfile)
          csv = CSV.parse(csv_text, headers: true, col_sep: ";", encoding: 'iso-8859-1')
          
          count = 0
          
          csv.each do |row|
            brand_name, code, title, type, variant = row
            unless brand_name[1].empty?
              brand = Brand.find_or_create_by(description: brand_name[1])
              product_type = ProductType.find_or_create_by(description: type[1])

              product = @company.products.find_or_create_by(description: title[1]) do |p|
                p.title = title[1]
                p.primary_code = code[1]
                p.price = 0
                p.brand_id = brand.id
                p.product_type_id = product_type.id
              end

              product.variants.create!(sku: code[1], price: 0, compare_price: 0, cost: 0, title: variant[1]) if product.persisted?
            end
          end
        end
    
        render json: count
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_product
        @product = Product.includes(:brand, :product_type, :variants).find(params[:id])
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

      def import_params
        params.permit(:company_id, :csv)
      end
    end
  end
end
