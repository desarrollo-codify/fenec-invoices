# frozen_string_literal: true

module Api
  module V1
    class ContingenciesController < ApplicationController
      # GET /api/v1/contingencies
      def index
        @contingencies = Contingency.all

        render json: @contingencies
      end
    end
  end
end
