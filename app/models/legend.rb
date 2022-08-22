# frozen_string_literal: true

class Legend < ApplicationRecord
  validates :code, presence: true
  validates :description, presence: true, format: { with: VALID_NAME_REGEX }

  def self.bulk_load(activities)
    upsert_all(activities)
  end

  def self.random
    order(Arel.sql('RANDOM()')).first
  end
end
