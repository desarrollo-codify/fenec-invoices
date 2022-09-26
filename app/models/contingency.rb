# frozen_string_literal: true

class Contingency < ApplicationRecord
  validates :start_date, presence: true

  belongs_to :point_of_sale
  belongs_to :significative_event

  scope :pending, -> { where(end_date: nil) }
  scope :need_cafc, -> { where('significative_event_id >= 5') }
  scope :no_manual, -> { where('significative_event_id < 5')  }

  def close!
    self.end_date = DateTime.now
    save
  end

  def manual_type?
    [1, 5, 6, 7].include? self.significative_event_id 
  end
end
