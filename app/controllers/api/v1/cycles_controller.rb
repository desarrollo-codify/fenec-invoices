# frozen_string_literal: true

module Api
  module V1
    class CyclesController < ApplicationController
      before_action :set_cycle, only: %i[show update destroy]

      # GET /api/v1/cycles
      def index
        @cycles = Cycle.all

        render json: @cycles
      end

      # GET /api/v1/cycles/1
      def show
        render json: @cycle
      end

      # POST /api/v1/cycles
      def create
        @cycle = Cycle.new(cycle_params)

        if @cycle.save
          render json: @cycle, status: :created, location: @cycle
        else
          render json: @cycle.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/cycles/1
      def update
        if @cycle.update(cycle_params)
          render json: @cycle
        else
          render json: @cycle.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/cycles/1
      def destroy
        @cycle.destroy
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_cycle
        @cycle = Cycle.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def cycle_params
        params.fetch(:cycle, {})
      end
    end
  end
end
