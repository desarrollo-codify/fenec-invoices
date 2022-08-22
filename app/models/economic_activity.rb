# frozen_string_literal: true

class EconomicActivity < ApplicationRecord
  validates :code, presence: true
  validates :description, presence: true, format: { with: VALID_NAME_REGEX }

  belongs_to :company
  has_many :legends, dependent: :destroy

  def initialize(attributes = {})
    super(attributes)
  end

  def bulk_load_legends(legends_list, _code)
    # a = legends_list.select{|a, b| a == code.to_i}
    legends.upsert_all(legends_list)
  end

  def random_legend
    legend = ''
    if legends.any?
      random_index = rand(legends.count)
      legend = legends[random_index]
    end
    legend
  end
end
