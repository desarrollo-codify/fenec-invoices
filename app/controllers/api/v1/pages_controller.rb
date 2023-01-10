# frozen_string_literal: true

module Api
  module V1
    class PagesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_page, only: %i[show update destroy]
      before_action :set_system_module, only: %i[index create]

      # GET /api/v1/system_module/id/pages
      def index
        @pages = @system_module.pages

        render json: @pages
      end

      # GET /api/v1/pages/1
      def show
        render json: @page
      end

      # POST /api/v1/system_module/id/pages
      def create
        @page = @system_module.pages.build(page_params)

        if @page.save
          render json: @page, status: :created
        else
          render json: @page.errors.full_messages, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/pages/1
      def update
        if @page.update(page_params)
          render json: @page
        else
          render json: @page.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/pages/1
      def destroy
        @page.destroy
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_page
        @page = Page.find(params[:id])
      end

      def set_system_module
        @system_module = SystemModule.find(params[:system_module_id])
      end

      # Only allow a list of trusted parameters through.
      def page_params
        params.require(:page).permit(:description)
      end
    end
  end
end
