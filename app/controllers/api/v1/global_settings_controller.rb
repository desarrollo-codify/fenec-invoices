class Api::V1::GlobalSettingsController < ApplicationController

  def significative_events
    @significative_events = SignificativeEvent.all
    render json: @significative_events
  end

  def cancellation_reasons
    @cancellation_reasons = CancellationReason.all
    render json: @cancellation_reasons
  end

  def countries
    @countries = Country.all
    render json: @countries
  end

  def document_types
    @document_types = DocumentType.all
    render json: @document_types
  end

  def issuance_types
    @issuance_types = IssuanceType.all
    render json: @issuance_types
  end
end
