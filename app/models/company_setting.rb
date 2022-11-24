# frozen_string_literal: true

class CompanySetting < ApplicationRecord
  validates :address, presence: true
  validates :port, presence: true, numericality: { only_integer: true, message: 'El Puerto debe ser un valor numérico.' }
  validates :domain, presence: true
  validates :user_name, presence: true, format: { with: VALID_EMAIL_REGEX }
  validates :password, presence: true

  belongs_to :company

  after_initialize :default_values, if: :new_record?

  private

  def default_values
    self.is_secure ||= true
  end
end
