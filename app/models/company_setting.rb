# frozen_string_literal: true

class CompanySetting < ApplicationRecord
  validates :address, presence: { message: 'La dirección no puede estar en blanco.' }
  validates :port, presence: { message: 'El puerto no puede estar en blanco.' },
                   numericality: { only_integer: true, message: 'El Puerto debe ser un valor numérico.' }
  validates :domain, presence: { message: 'El dominio no puede estar en blanco.' }
  validates :user_name, presence: { message: 'El usuario no puede estar en blanco.' }, format: { with: VALID_EMAIL_REGEX }
  validates :password, presence: { message: 'La contraseña no puede estar en blanco.' }

  belongs_to :company

  after_initialize :default_values, if: :new_record?
  before_create :confirmation_token

  def email_activate
    self.mail_verification = true
    self.confirm_token = nil
    save!(validate: false)
  end

  private

  def default_values
    self.is_secure ||= true
  end

  def confirmation_token
    self.confirm_token = SecureRandom.urlsafe_base64.to_s if confirm_token.blank?
  end
end
