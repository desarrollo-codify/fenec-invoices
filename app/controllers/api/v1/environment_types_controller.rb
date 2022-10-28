# frozen_string_literal: true

module Api
  module V1
    class EnvironmentTypesController < ApplicationController
      def index
        @environment_types = EnvironmentType.all

        render json: @environment_types
      end
    end
  end
end
