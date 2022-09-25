# frozen_string_literal: true

module Api
  module V1
    class CompaniesController < ApplicationController
      # before_action :authenticate_user!
      # before_action :super_admin_only, only: %i[index destroy]
      before_action :set_company, only: %i[show update destroy]

      # GET /companies
      def index
        @companies = Company.all

        render json: @companies.map { |company|
                       next unless company.logo.attached?

                       company.as_json.merge(
                         logo: url_for(company.logo)
                       )
                     }
      end

      # GET /companies/1
      def show
        result = @company.as_json(except: %i[created_at updated_at],
                                  include: [{ economic_activities: { except: %i[created_at
                                                                                updated_at company_id] } },
                                            branch_offices: { except: %i[created_at updated_at] },
                                            company_setting: { except: %i[created_at
                                                                          updated_at company_id] },
                                            page_size: { only: %i[description] }])

        result = result.merge(logo: url_for(@company.logo)) if @company.logo&.attached?
        render json: result
      end

      # POST /companies
      def create
        @company = Company.new(company_params)

        if @company.save
          render json: @company, status: :created
        else
          render json: @company.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /companies/1
      def update
        if @company.update(company_params)
          @company.logo.attach(company_params[:logo]) if company_params[:logo]
          render json: @company
        else
          render json: @company.errors, status: :unprocessable_entity
        end
      end

      # DELETE /companies/1
      def destroy
        @company.destroy
      end

      # GET /companies/1/logo
      def logo
        company = Company.find(params[:id])

        if company&.logo&.attached?
          render json: url_for(company.logo)
        else
          head :not_found
        end
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_company
        @company = Company.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def company_params
        params.require(:company).permit(:name, :nit, :address, :phone, :logo, :page_size_id)
      end

      def super_admin_only
        render json: { message: 'Only admin users.' }, status: :unauthorized unless current_user.super_admin?
      end
    end
  end
end
