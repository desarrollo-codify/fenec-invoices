# frozen_string_literal: true

class ContingencyCode < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :document_sector_code, presence: true, numericality: {
    message: 'El Codigo de documento Sector debe ser un valor numérico.'
  }
  validates :limit, presence: true, numericality: {
    message: 'El limite debe ser un valor numérico.'
  }
  validates :current_use, presence: true, numericality: {
    less_than_or_equal_to: :limit
  }
  validates :available, presence: true

  after_initialize :default_values
  after_update :availability_of_current_use

  belongs_to :economic_activity

  private

  def default_values
    self.current_use ||= 0
    self.available ||= true
  end

  def availability_of_current_use
    update_column(available: false) if current_use == limit
  end
end