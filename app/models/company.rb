# frozen_string_literal: true

class Company < ApplicationRecord
  validates :name, presence: true, uniqueness: true, format: { with: VALID_NAME_REGEX }
  validates :nit, presence: true, numericality: { only_integer: true, message: 'El NIT debe ser un valor numérico.' }
  validates :address, presence: true

  has_one_attached :logo
  has_many :branch_offices, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :invoices, through: :branch_offices
  has_many :clients, dependent: :destroy
  has_many :delegated_tokens, dependent: :destroy
  has_many :economic_activities, dependent: :destroy
  has_many :invoices, through: :branch_offices
  has_one :mail_setting, dependent: :destroy

  def bulk_load_economic_activities(activities)
    economic_activities.upsert_all(activities, unique_by: %i[company_id code])
  end
end
