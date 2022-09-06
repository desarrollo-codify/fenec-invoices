# frozen_string_literal: true

module Api
  module V1
    class SignificativeEventsController < ApplicationController
      # GET /api/v1/significative_events
      def index
        @significative_events = SignificativeEvent.all

        render json: @significative_events
      end
    end
  end
end
