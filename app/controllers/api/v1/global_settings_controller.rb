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

  def room_types
    @room_types = RoomType.all
    render json: @room_types
  end

  def payment_methods
    @payment_methods = PaymentMethod.all
    render json: @payment_methods
  end

  def currency_types
    @currency_types = CurrencyType.all
    render json: @currency_types
  end

  def pos_types
    @currency_types = PosType.all
    render json: @currency_types
  end
end
