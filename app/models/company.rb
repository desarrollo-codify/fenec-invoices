# frozen_string_literal: true

class Company < ApplicationRecord
  validates :name, presence: true, uniqueness: true, format: { with: VALID_NAME_REGEX }
  validates :nit, presence: true, numericality: { only_integer: true, message: 'El NIT debe ser un valor numérico.' }
  validates :address, presence: true

  belongs_to :page_size, optional: true
  has_one_attached :logo
  has_many :branch_offices, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :invoices, through: :branch_offices
  has_many :clients, dependent: :destroy
  has_many :delegated_tokens, dependent: :destroy
  has_many :economic_activities, dependent: :destroy
  has_many :invoices, through: :branch_offices
  has_many :accounting_transactions, dependent: :destroy
  has_one :company_setting, dependent: :destroy
  has_many :cycles
  has_many :accounts
  has_many :users
  has_many :exchange_rates, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :product_codes, through: :economic_activities
  belongs_to :environment_type, optional: true
  belongs_to :modality, optional: true
  has_and_belongs_to_many :invoice_types, optional: true
  has_and_belongs_to_many :document_sector_types, optional: true
  has_and_belongs_to_many :measurements, optional: true

  after_initialize :default_values, if: :new_record?
  after_create :add_branch_office_and_pos
  after_create :add_company_setting

  def bulk_load_economic_activities(activities)
    economic_activities.upsert_all(activities, unique_by: %i[company_id code])
  end

  private

  def default_values
    self.page_size_id ||= 1 unless Rails.env.test?
  end

  def add_branch_office_and_pos
    branch_offices.create(name: 'Casa Matriz', number: 0, city: 'Santa Cruz')
  end

  def add_company_setting
    CompanySetting.create(address: 'set address...', port: 0, domain: 'domain...', user_name: 'user@domain.com',
                          password: 'email account pwd...', company_id: id)
  end
end
