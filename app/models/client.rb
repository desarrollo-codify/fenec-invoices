# frozen_string_literal: true

class Client < ApplicationRecord
  validates :name, presence: true
  validates :nit, presence: true
  validates :email, format: { with: VALID_EMAIL_REGEX }

  belongs_to :company
  belongs_to :document_type

  before_create do
    self.code = if Client.where.not(code: nil).last
                  (Client.where.not(code: nil).last.code.to_i + 1).to_s.rjust(5, '0')
                else
                  '1'.rjust(5, '0')
                end
  end
end
