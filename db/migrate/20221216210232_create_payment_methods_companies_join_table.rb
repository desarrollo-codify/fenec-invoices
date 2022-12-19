# frozen_string_literal: true

class CreatePaymentMethodsCompaniesJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :companies, :payment_methods
  end
end
