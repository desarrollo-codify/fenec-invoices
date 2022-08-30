# frozen_string_literal: true

class Contingency < ApplicationRecord
  validates :start_date, presence: true

  belongs_to :branch_office
  belongs_to :significative_event
end
