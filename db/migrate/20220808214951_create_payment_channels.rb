# frozen_string_literal: true

class CreatePaymentChannels < ActiveRecord::Migration[7.0]
  def change
    create_table :payment_channels do |t|
      t.string :description

      t.timestamps
    end
  end
end
