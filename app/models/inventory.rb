# frozen_string_literal: true

class Inventory < ApplicationRecord
  belongs_to :branch_office
  belongs_to :variant
end
