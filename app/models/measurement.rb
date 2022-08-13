class Measurement < ApplicationRecord
  validates :description, presence: true
end
