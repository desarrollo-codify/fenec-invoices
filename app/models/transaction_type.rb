# frozen_string_literal: true

class TransactionType < ApplicationRecord
	validates :description, presence: true
end
