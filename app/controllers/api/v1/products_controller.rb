class Api::V1::ProductsController < ApplicationController
  before_action :set_product, only: %i[ show update destroy ]
  before_action :set_company, only: %i[ index create ]

  # GET /api/v1/companies/:company_id/products
  def index
    @products = @company.products
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
end
