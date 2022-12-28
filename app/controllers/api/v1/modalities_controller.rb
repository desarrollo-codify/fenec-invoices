# frozen_string_literal: true

module Api
  module V1
    class ModalitiesController < ApplicationController
      before_action :authenticate_user!
      
      def index
        @modalities = Modality.all

        render json: @modalities
      end
    end
  end
end
