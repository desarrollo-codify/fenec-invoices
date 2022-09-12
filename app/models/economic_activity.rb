# frozen_string_literal: true

class EconomicActivity < ApplicationRecord
  validates :code, presence: true
  validates :description, presence: true, format: { with: VALID_NAME_REGEX }

  belongs_to :company
  has_many :legends, dependent: :destroy
  has_many :document_sectors, dependent: :destroy
  has_many :contingency_codes, dependent: :destroy

  def initialize(attributes = {})
    super(attributes)
  end

  def bulk_load_legends(legends_list)
    legends.upsert_all(legends_list, unique_by: %i[economic_activity_id description])
  end

  def bulk_load_document_sectors(document_sectors_list)
    document_sectors.upsert_all(document_sectors_list, unique_by: %i[economic_activity_id code])
  end

  def random_legend
    legends.order(Arel.sql('RANDOM()')).first if legends.any?
  end
end
