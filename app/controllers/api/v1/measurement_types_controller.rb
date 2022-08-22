# frozen_string_literal: true

module Api
  module V1
    class MeasurementTypesController < ApplicationController
      # GET /api/v1/measurement_types
      def index
        @measurement_types = Legend.all

        render json: @measurement_types
      end
    end
  end
end
