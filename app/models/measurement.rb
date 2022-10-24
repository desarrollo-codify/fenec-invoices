# frozen_string_literal: true

class Measurement < ApplicationRecord
  validates :description, presence: true

  has_and_belongs_to_many :companies

  def self.bulk_load(measurements)
    upsert_all(measurements)
  end
end
