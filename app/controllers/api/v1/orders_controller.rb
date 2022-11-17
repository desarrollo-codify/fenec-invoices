class Api::V1::OrdersController < ApplicationController
  def update
    @order = Order.find(params[:id])
    if @order.update(order_params)
      render json: @order
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  private

  def order_params
    params.require(:order).permit(:invoice_id, :date, :total_discount)
  end
end
