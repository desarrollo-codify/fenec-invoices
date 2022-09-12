# frozen_string_literal: true

module Api
  module V1
    class GlobalSettingsController < ApplicationController
      def significative_events
        @significative_events = SignificativeEvent.all.order(:code)
        render json: @significative_events
      end

      def cancellation_reasons
        @cancellation_reasons = CancellationReason.all.order(:code)
        render json: @cancellation_reasons
      end

      def countries
        @countries = Country.all.order(:code)
        render json: @countries
      end

      def document_types
        @document_types = DocumentType.all.order(:code)
        render json: @document_types
      end

      def issuance_types
        @issuance_types = IssuanceType.all.order(:code)
        render json: @issuance_types
      end

      def room_types
        @room_types = RoomType.all.order(:code)
        render json: @room_types
      end

      def payment_methods
        @payment_methods = PaymentMethod.all.order(:code)
        render json: @payment_methods
      end

      def currency_types
        @currency_types = CurrencyType.all.order(:code)
        render json: @currency_types
      end

      def pos_types
        @pos_types = PosType.all.order(:code)
        render json: @pos_types
      end

      def invoice_types
        @invoice_types = InvoiceType.all.order(:code)
        render json: @invoice_types
      end

      def measurement_types
        @measurement_types = Measurement.all.order(:id)
        render json: @measurement_types
      end

      def service_messages
        @service_messages = ServiceMessage.all.order(:code)
        render json: @service_messages
      end

      def document_sector_types
        @document_sector_types = DocumentSectorType.all.order(:code)
        render json: @document_sector_types
      end
    end
  end
end
