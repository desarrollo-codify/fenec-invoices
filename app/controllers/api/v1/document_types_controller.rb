class Api::V1::DocumentTypesController < ApplicationController
  def index
    @document_type = DocumentType.all

    render json: @document_type
  end
end
