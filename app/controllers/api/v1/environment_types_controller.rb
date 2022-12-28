# frozen_string_literal: true

module Api
  module V1
    class EnvironmentTypesController < ApplicationController
      before_action :authenticate_user!
      def index
        @environment_types = EnvironmentType.all

        render json: @environment_types
      end
    end
  end
end
