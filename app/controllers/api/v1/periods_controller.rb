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
        @errors = []
        @period = @cycle.periods.build(period_params)
        validate!(period_params)

        return render json: @errors, status: :unprocessable_entity if @errors.any?

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

      def validate!(_params)
        if @cycle.periods.current.present?
          @errors << "No es posible abrir un periodo mientras el periodo #{@cycle.periods.current.description} esté abierto."
        end
        if @period.start_date.present? && @period.end_date.present? && @period.start_date >= @period.end_date
          @errors << 'La fecha de fin no puede ser anterior a la del inicio.'
        end
        previous_periods = Period.where('end_date <= ?', @period.start_date)
        @errors << 'La fecha de inicio no debe sobreponerse a otros periodos de la misma gestión.' if previous_periods.exists?
      end

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
