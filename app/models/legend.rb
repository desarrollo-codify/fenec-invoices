# frozen_string_literal: true

class Legend < ApplicationRecord
  validates :code, presence: true
  validates :description, presence: true, format: { with: VALID_NAME_REGEX }

  belongs_to :economic_activity

  def random
    order(Arel.sql('RANDOM()')).first
  end
end
