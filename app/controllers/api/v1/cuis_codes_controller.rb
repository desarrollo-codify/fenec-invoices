# frozen_string_literal: true

module Api
  module V1
    class CuisCodesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_branch_office, only: %i[index current]

      # GET /api/v1/branch_offices/:branch_office_id/cuis_codes
      def index
        @cuis_codes = @branch_office.cuis_codes

        render json: @cuis_codes
      end

      # GET /api/v1/branch_offices/:branch_office_id/current
      def current
        @cuis_code = @branch_office.cuis_codes.by_pos(params[:point_of_sale]).current
        if @cuis_code.present?
          render json: @cuis_code
        else
          error_message = 'La sucursal no cuenta con un codigo diario CUFD.'
          render json: { message: error_message }, status: :not_found
        end
      end

      private

      def set_branch_office
        @branch_office = BranchOffice.find(params[:branch_office_id])
      end
    end
  end
end
