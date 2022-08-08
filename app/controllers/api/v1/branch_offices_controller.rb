class Api::V1::BranchOfficesController < ApplicationController
  before_action :set_branch_office, only: %i[ show update destroy ]

  # GET /api/v1/branch_offices
  def index
    # TODO: send offices by company
    @branch_offices = BranchOffice.all

    render json: @branch_offices
  end

  # GET /api/v1/branch_offices/1
  def show
    render json: @branch_office
  end

  # POST /api/v1/branch_offices
  def create
    @branch_office = BranchOffice.new(create_branch_office_params)

    if @branch_office.save
      render json: @branch_office, status: :created, location: @branch_office
    else
      render json: @branch_office.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/branch_offices/1
  def update
    if @branch_office.update(update_branch_office_params)
      render json: @branch_office
    else
      render json: @branch_office.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/branch_offices/1
  def destroy
    @branch_office.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_branch_office
      @branch_office = BranchOffice.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def create_branch_office_params
      params.require(:branch_office).permit(:name, :phone, :address, :city, :number, :company_id)
    end

    def update_branch_office_params
      params.require(:branch_office).permit(:name, :phone, :address, :city, :number)
    end
end
