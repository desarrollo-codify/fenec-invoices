# frozen_string_literal: true

module Api
  module V1
    class SystemModulesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_system_module, only: %i[show update destroy]

      # GET /api/v1/system_modules
      def index
        @system_modules = SystemModule.all

        render json: @system_modules
      end

      # GET /api/v1/system_modules/1
      def show
        render json: @system_module
      end

      # POST /api/v1/system_modules
      def create
        @system_module = SystemModule.new(system_module_params)

        if @system_module.save
          render json: @system_module, status: :created
        else
          render json: @system_module.errors.full_messages, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/system_modules/1
      def update
        if @system_module.update(system_module_params)
          render json: @system_module
        else
          render json: @system_module.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/system_modules/1
      def destroy
        @system_module.destroy
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_system_module
        @system_module = SystemModule.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def system_module_params
        params.require(:system_module).permit(:description)
      end
    end
  end
end
