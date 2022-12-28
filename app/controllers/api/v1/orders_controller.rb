# frozen_string_literal: true

module Api
  module V1
    class OrdersController < ApplicationController
      before_action :authenticate_user!
      
      def update
        @order = Order.find(params[:id])
        if @order.update(order_params)
          render json: @order
        else
          render json: @order.errors.full_messages, status: :unprocessable_entity
        end
      end

      private

      def order_params
        params.require(:order).permit(:invoice_id, :date, :total_discount)
      end
    end
  end
end
