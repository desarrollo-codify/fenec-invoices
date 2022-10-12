# frozen_string_literal: true

class InvoiceLog < ApplicationRecord
  belongs_to :invoice
end
