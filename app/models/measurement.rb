# frozen_string_literal: true

class Measurement < ApplicationRecord
  validates :description, presence: true

  def self.bulk_load(measurements)
    upsert_all(measurements)
  end
end
