# frozen_string_literal: true

class User < ApplicationRecord
  enum role: %i[user admin super_admin]
  after_initialize :set_default_role, if: :new_record?

  def set_default_role
    self.role ||= :user
  end
end
