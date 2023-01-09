# frozen_string_literal: true

module Api
  module V1
    class PeriodsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_period, only: %i[update close]
      before_action :set_cycle, only: %i[index create]

      # GET /api/v1/cycles/1/periods
      def index
        @periods = @cycle.periods

        render json: @periods
      end

      # POST /api/v1/cycles/1/periods
      def create
        if @cycle.periods.current.present?
          return render json: { message: "No se puede abrir un periodo ya que esta abierto el periodo '#{@cycle.periods.current.description}'." },
                        status: :unprocessable_entity
        end

        @period = @cycle.periods.build(period_params)

        if @period.save
          render json: @period, status: :created
        else
          render json: @period.errors.full_messages, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/periods/1
      def update
        if @period.update(period_params)
          render json: @period
        else
          render json: @period.errors.full_messages, status: :unprocessable_entity
        end
      end

      # POST /api/v1/periods/1
      def close
        @period.status = 'CERRADO'
        @period.save

        render json: { message: "Se ha cerrado el periodo #{@period.description}." }
      end

      # POST /api/v1/cycles/1/periods/current
      def current
        @period = @cycle.periods.current

        unless @period.present?
          return render json: { message: "No existen un periodo abierta para la gestión #{@cycle.year}." },
                        status: :unprocessable_entity
        end

        render json: @period
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_period
        @period = Period.find(params[:id])
      end

      def set_cycle
        @cycle = Cycle.find(params[:cycle_id])
      end

      # Only allow a list of trusted parameters through.
      def period_params
        params.require(:period).permit(:description, :start_date, :end_date, :status)
      end
    end
  end
end
