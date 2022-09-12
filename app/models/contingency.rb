# frozen_string_literal: true

class Contingency < ApplicationRecord
  validates :start_date, presence: true

  belongs_to :branch_office
  belongs_to :significative_event

  scope :pending, -> { where(end_date: nil) }
  scope :need_cafc, -> { where('significative_event_id >= 5') }

  def close!
    self.end_date = DateTime.now
    save
  end
end
