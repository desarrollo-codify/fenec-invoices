# frozen_string_literal: true

module Api
  module V1
    class ExchangeRatesController < ApplicationController
      before_action :set_exchange_rate, only: %i[show update destroy]
      before_action :set_company, only: %i[index create find_exchange_rate_by_date]

      # GET /api/v1/companies/1/exchange_rates
      def index
        @exchange_rates = @company.exchange_rates.order(date: :desc)

        render json: @exchange_rates
      end

      # GET /api/v1/exchange_rates/1
      def show
        render json: @exchange_rate
      end

      # POST /api/v1/companies/1/exchange_rates
      def create
        @exchange_rate = @company.exchange_rates.build(exchange_rate_params)
        if @exchange_rate.save
          render json: @exchange_rate, status: :created
        else
          render json: @exchange_rate.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/exchange_rates/1
      def update
        if @exchange_rate.update(exchange_rate_params)
          render json: @exchange_rate
        else
          render json: @exchange_rate.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/exchange_rates/1
      def destroy
        @exchange_rate.destroy
      end

      def find_exchange_rate_by_date
        date = params[:date].to_date
        @exchange_rate = @company.exchange_rates.by_date(date)

        if @exchange_rate.blank?
          return render json: { message: "No se encontro ningun tipo de cambio en la fecha #{date}" },
                        status: :unprocessable_entity
        end
        debugger
        render json: @exchange_rate
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_exchange_rate
        @exchange_rate = ExchangeRate.find(params[:id])
      end

      def set_company
        @company = Company.find(params[:company_id])
      end

      # Only allow a list of trusted parameters through.
      def exchange_rate_params
        params.require(:exchange_rate).permit(:date, :rate, :company_id)
      end
    end
  end
end
