# frozen_string_literal: true

module Api
  module V1
    class DocumentTypesController < ApplicationController
      # GET /api/v1/document_types
      def index
        @document_types = DocumentType.all

        render json: @document_types
      end
    end
  end
end
