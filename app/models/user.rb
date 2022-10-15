# frozen_string_literal: true

class User < ApplicationRecord
  extend Devise::Models
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  enum role: %i[super_admin admin operator]
  after_initialize :set_default_role, if: :new_record?

  belongs_to :company, optional: true

  scope :by_company, ->(id) { where(company_id: id) }

  def set_default_role
    self.role ||= :operator
  end
end
