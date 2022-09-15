class Api::V1::CuisCodesController < ApplicationController
  before_action :set_branch_office, only: %i[index current]
 
  # GET /api/v1/branch_offices/:branch_office_id/cuis_codes
  def index
    @cuis_codes = @branch_office.cuis_codes

    render json: @cuis_codes
  end

  # GET /api/v1/branch_offices/:branch_office_id/current_code
  def current
    @cuis_code = @branch_office.cuis_codes.where(point_of_sale: params[:point_of_sale]).current
    if @cuis_code.present?
      render json: @cuis_code
    else
      error_message = 'La sucursal no cuenta con un codigo diario CUFD.'
      render json: error_message, status: :not_found
    end
  end

  private
  
  def set_branch_office
    @branch_office = BranchOffice.find(params[:branch_office_id])
  end
end
