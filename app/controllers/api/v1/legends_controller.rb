# frozen_string_literal: true

module Api
  module V1
    class LegendsController < ApplicationController
      # GET /api/v1/legends
      def index
        @legends = Legend.all

        render json: @legends
      end
    end
  end
end
