# frozen_string_literal: true

class DropPaymentChannel < ActiveRecord::Migration[7.0]
  def change
    drop_table :payment_channels
  end
end
