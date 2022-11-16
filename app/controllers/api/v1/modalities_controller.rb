# frozen_string_literal: true

module Api
  module V1
    class ModalitiesController < ApplicationController
      def index
        @modalities = Modality.all

        render json: @modalities
      end
    end
  end
end
