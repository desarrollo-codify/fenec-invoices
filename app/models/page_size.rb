# frozen_string_literal: true

class PageSize < ApplicationRecord
  validates :description, presence: true
end
