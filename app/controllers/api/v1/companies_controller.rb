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

        render json: @companies
      end

      # GET /companies/1
      def show
        render json: @company
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
          render json: @company
        else
          render json: @company.errors, status: :unprocessable_entity
        end
      end

      # DELETE /companies/1
      def destroy
        @company.destroy
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_company
        @company = Company.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def company_params
        params.require(:company).permit(:name, :nit, :address, :phone, :logo)
      end

      def super_admin_only
        render json: { message: 'Only admin users.' }, status: :unauthorized unless current_user.super_admin?
      end
    end
  end
end
