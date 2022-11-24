# frozen_string_literal: true

class OrderCustomer < ApplicationRecord
  belongs_to :order
end
