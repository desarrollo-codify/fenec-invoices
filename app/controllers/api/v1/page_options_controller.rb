# frozen_string_literal: true

module Api
  module V1
    class PageOptionsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_page_option, only: %i[show update destroy]
      before_action :set_page, only: %i[index create]

      # GET /api/v1/page/id/page_options
      def index
        @page_options = @page.page_options

        render json: @page_options
      end

      # GET /api/v1/page_options/1
      def show
        render json: @page_option
      end

      # POST /api/v1/page/id/page_options
      def create
        @page_option = @page.page_options.build(page_option_params)

        if @page_option.save
          render json: @page_option, status: :created
        else
          render json: @page_option.errors.full_messages, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/page_options/1
      def update
        if @page_option.update(page_option_params)
          render json: @page_option
        else
          render json: @page_option.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/page_options/1
      def destroy
        @page_option.destroy
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_page_option
        @page_option = PageOption.find(params[:id])
      end

      def set_page
        @page = Page.find(params[:page_id])
      end

      # Only allow a list of trusted parameters through.
      def page_option_params
        params.require(:page_option).permit(:code, :description)
      end
    end
  end
end
