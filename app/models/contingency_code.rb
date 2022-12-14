# frozen_string_literal: true

class ContingencyCode < ApplicationRecord
  validates :code, presence: { message: 'El código no puede estar en blanco.' }, uniqueness: true
  validates :document_sector_code, presence: { message: 'La tipo de documento sector no puede estar en blanco.' }, numericality: {
    message: 'El Codigo de documento Sector debe ser un valor numérico.'
  }
  validates :limit, presence: { message: 'El límite no puede estar en blanco.' }, numericality: {
    message: 'El limite debe ser un valor numérico.'
  }
  validates :current_use, presence: { message: 'El uso actual no puede estar en blanco.' }, numericality: {
    less_than_or_equal_to: :limit
  }
  validates :available, inclusion: { in: [true, false] }

  after_initialize :default_values
  after_commit :availability_of_current_use

  belongs_to :economic_activity

  scope :available, -> { where(available: true) }

  def increment!
    self.current_use += 1
    save!
  end

  private

  def default_values
    return unless new_record?

    self.current_use ||= 0
    self.available ||= true
  end

  def availability_of_current_use
    update_column(:available, false) if current_use == limit
  end
end
