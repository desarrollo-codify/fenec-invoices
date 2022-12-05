# frozen_string_literal: true

class CompanySetting < ApplicationRecord
  validates :address, presence: true
  validates :port, presence: true, numericality: { only_integer: true, message: 'El Puerto debe ser un valor numérico.' }
  validates :domain, presence: true
  validates :user_name, presence: true, format: { with: VALID_EMAIL_REGEX }
  validates :password, presence: true

  belongs_to :company

  after_initialize :default_values, if: :new_record?
  before_create :confirmation_token

  def email_activate
    self.mail_verification = true
    self.confirm_token = nil
    save!(:validate => false)
  end

  private

  def default_values
    self.is_secure ||= true
  end

  def confirmation_token
    if self.confirm_token.blank?
      self.confirm_token = SecureRandom.urlsafe_base64.to_s
    end
  end
end
