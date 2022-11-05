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

      # POST /api/v1/companies/1/products/import
      def import
        if import_params[:csv].content_type.include?('csv')
          csv_text = File.read(import_params[:csv].tempfile)
          csv = CSV.parse(csv_text, headers: true, col_sep: ',', encoding: 'iso-8859-1')

          count = 0
          count_total = 0
          errors = []

          csv.each do |row|
            brand_name, code, title, type, variant, price, measure, category_name = row
            next if brand_name[1].empty?

            brand = Brand.find_or_create_by(description: brand_name[1]) if brand_name[1].present?
            product_type = ProductType.find_or_create_by(description: type[1]) if type[1].present?
            measurement = Measurement.find_by(description: measure[1]) if measure[1].present?
            category = ProductCategory.find_or_create_by(description: category_name[1]) if category_name[1].present?

            product = @company.products.find_or_create_by(description: title[1]) do |p|
              p.title = title[1]
              p.primary_code = code[1]
              p.price = price[1].present? ? price[1] : 0
              p.brand_id = brand.id if brand.present?
              p.product_type_id = product_type.id if product_type.present?
              p.measurement_id = measurement.id if measurement.present?
              p.category_id = category.id if category.present?
            end
            unless product.valid?
              errors << "El producto #{count}, con el titulo '#{title[1]}' no se pudo crear por: #{product.errors.full_messages}"
              count_total += 1
              next
            end
            product.variants.create!(sku: code[1], price: 0, compare_price: 0, cost: 0, title: variant[1]) if product.persisted?
            count_total += 1
            count += 1 if product.persisted?
          end
        end
        unless count == count_total
          response = "Se han importado #{count} de #{count_total} productos. Estos productos no se pudieron crear: #{errors}"
        end
        response = "Se han importado #{count} productos." if count == count_total
        render json: response
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
        params.require(:product).permit(:primary_code, :description, :sin_code, :price, :measurement_id)
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
