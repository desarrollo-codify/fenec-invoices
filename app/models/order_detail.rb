# frozen_string_literal: true

class OrderDetail < ApplicationRecord
  belongs_to :order
end
