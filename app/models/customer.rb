class Customer < ApplicationRecord
  validates :name, presence: { message: 'El nombre no puede estar en blanco.' }
  validates :nit, presence: { message: 'El nit no puede estar en blanco.' }
  validates :email, format: { with: VALID_EMAIL_REGEX }

  belongs_to :company
  belongs_to :document_type

  before_create do
    self.code = if company.customers.where.not(code: nil).last
                  (company.customers.where.not(code: nil).last.code.to_i + 1).to_s.rjust(5, '0')
                else
                  '1'.rjust(5, '0')
                end
  end
end
