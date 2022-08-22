# frozen_string_literal: true

class Legend < ApplicationRecord
  validates :code, presence: true
  validates :description, presence: true, format: { with: VALID_NAME_REGEX }

  belongs_to :economic_activity

  def self.bulk_load(activities)
    upsert_all(activities, unique_by: %i[economic_activity_id code])
  end

  def self.random
    order(Arel.sql('RANDOM()')).first
  end
end
