# frozen_string_literal: true

class EconomicActivity < ApplicationRecord
  validates :code, presence: { message: 'El código no puede estar en blanco.' }
  validates :description, presence: { message: 'La descripción no puede estar en blanco.' }, format: { with: VALID_NAME_REGEX }

  belongs_to :company
  has_many :legends, dependent: :destroy
  has_many :document_sectors, dependent: :destroy
  has_many :product_codes, dependent: :destroy
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

  def bulk_load_product_codes(product_codes_list)
    product_codes.upsert_all(product_codes_list, unique_by: %i[economic_activity_id code])
  end

  def random_legend
    legends.order(Arel.sql('RANDOM()')).first if legends.any?
  end
end
