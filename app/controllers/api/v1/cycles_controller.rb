# frozen_string_literal: true

module Api
  module V1
    class CyclesController < ApplicationController
      before_action :set_cycle, only: %i[show update destroy]
      before_action :set_company, only: %i[index create current]

      # GET /api/v1/cycles
      def index
        @cycles = @company.cycles

        render json: @cycles
      end

      # GET /api/v1/cycles/1
      def show
        render json: @cycle
      end

      # POST /api/v1/cycles
      def create
        @cycle = @company.cycles.build(cycle_params)

        if @cycle.save
          render json: @cycle, status: :created, location: @cycle
        else
          render json: @cycle.errors.full_messages, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/cycles/1
      def update
        if @cycle.update(cycle_params)
          render json: @cycle
        else
          render json: @cycle.errors.full_messages, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/cycles/1
      def destroy
        @cycle.destroy
      end

      def current
        @cycle = @company.cycles.current

        return render json: { message: 'No existen una Gestión abierta para esta empresa.' }, status: :unprocessable_entity unless @cycle.present?

        render json: @cycle
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_cycle
        @cycle = Cycle.find(params[:id])
      end

      def set_company
        @company = Company.find(params[:company_id])
      end

      # Only allow a list of trusted parameters through.
      def cycle_params
        params.fetch(:cycle, {})
      end
    end
  end
end
