# frozen_string_literal: true

class Contingency < ApplicationRecord
  validates :start_date, presence: true

  belongs_to :point_of_sale
  belongs_to :significative_event
  has_many :invoices
  has_many :contingency_logs, dependent: :destroy

  scope :pending, -> { where(end_date: nil) }
  scope :manual, -> { where('significative_event_id >= 5') }
  scope :automatic, -> { where('significative_event_id < 5') }

  def close!
    self.end_date = DateTime.now
    save
  end

  def manual_type?
    [1, 5, 6, 7].include? significative_event_id
  end
end
