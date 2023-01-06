class Api::V1::CustomersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company, only: %i[index create]
  before_action :set_customer, only: %i[update destroy]

  def index
    @customers = @company.customers.all
    render json: @customers
  end

  def create
    @customer = @company.customers.build(customer_params)
    if @customer.save
      render json: @customer, status: :created
    else
      render json: @customer.errors, status: :unprocessable_entity
    end
  end

  def update
    if @customer.update(customer_params)
      render json: @customer
    else
      render json: @customer.errors, status: :unprocessable_entity
    end
  end
  
  def destroy
    @customer.destroy
  end

  private

  def customer_params
    params.require(:customer).permit(:code, :name, :nit, :phone, :email, :complement, :document_type_id)
  end

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def set_company
    @company = Company.find(params[:company_id])
  end
end
