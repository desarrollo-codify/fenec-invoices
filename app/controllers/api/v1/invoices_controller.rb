# frozen_string_literal: true

module Api
  module V1
    class InvoicesController < ApplicationController
      before_action :set_invoice, only: %i[show update destroy]
      before_action :set_branch_office, only: %i[index create]

      # GET /api/v1/invoices
      def index
        @invoices = @branch_office.invoices # or company?

        render json: @invoices
      end

      # GET /api/v1/invoices/1
      def show
        render json: @invoice
      end

      # POST /api/v1/invoices
      def create
        @invoice = @branch_office.invoices.build(invoice_params)

        if @invoice.save
          render json: @invoice, status: :created, location: @invoice
        else
          render json: @invoice.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/invoices/1
      def update
        if @invoice.update(invoice_params)
          render json: @invoice
        else
          render json: @invoice.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/invoices/1
      def destroy
        @invoice.destroy
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_invoice
        @invoice = Invoice.find(params[:id])
      end

      def set_branch_office
        @branch_office = BranchOffice.find(params[:branch_office_id])
      end

      # Only allow a list of trusted parameters through.
      def invoice_params
        # TODO: refactor this for unnecessary params when creating, like cancellation_date
        # TODO: add strong params for details
        params.require(:invoice).permit(:number, :date, :company_name, :company_nit, :business_name, :business_nit,
                                        :authorization, :key, :end_date, :activity_type, :control_code, :qr_content,
                                        :subtotal, :discount, :total, :paid, :change, :cancellation_date, :exchange_rate,
                                        :cuis_code, :cufd_code)
      end
    end
  end
end
