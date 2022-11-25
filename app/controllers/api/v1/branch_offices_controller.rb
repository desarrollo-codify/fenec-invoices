# frozen_string_literal: true

module Api
  module V1
    class BranchOfficesController < ApplicationController
      before_action :set_branch_office, only: %i[show update destroy contingencies]
      before_action :set_company, only: %i[index create]

      # GET /api/v1/companies/:company_id/branch_offices
      def index
        @branch_offices = @company.branch_offices

        render json: @branch_offices
      end

      # GET /api/v1/branch_offices/1
      def show
        render json: @branch_office
      end

      # POST /api/v1/companies/:company_id/branch_offices
      def create
        @branch_office = @company.branch_offices.build(branch_office_params)

        if @branch_office.save
          render json: @branch_office, status: :created
        else
          render json: @branch_office.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/branch_offices/1
      def update
        if @branch_office.update(branch_office_params)
          render json: @branch_office
        else
          render json: @branch_office.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/branch_offices/1
      def destroy
        @branch_office.destroy
      end

      def contingencies
        @contingencies = @branch_office.contingencies.includes(:significative_event, point_of_sale: :branch_office)

        render json: @contingencies.as_json(include: [
                                              { significative_event: { except: %i[created_at updated_at] } },
                                              {
                                                point_of_sale: { include: { branch_office: { only: %i[id name number] } },
                                                                 except: %i[created_at updated_at company_id] }
                                              }
                                            ])
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_branch_office
        @branch_office = BranchOffice.find(params[:id])
      end

      def set_company
        @company = Company.find(params[:company_id])
      end

      # Only allow a list of trusted parameters through.
      def branch_office_params
        params.require(:branch_office).permit(:name, :phone, :address, :city, :number, :page_size_id)
      end
    end
  end
end
