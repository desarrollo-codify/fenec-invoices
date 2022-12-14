# frozen_string_literal: true

class Order < ApplicationRecord
  has_many :order_details, dependent: :destroy
  has_one :order_customer, dependent: :destroy
  belongs_to :company
  belongs_to :invoice, optional: true
  has_many :tags, as: :taggable
end
