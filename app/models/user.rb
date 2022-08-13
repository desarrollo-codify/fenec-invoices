# frozen_string_literal: true

class User < ApplicationRecord
  enum role: %i[user admin super_admin]
  after_initialize :set_default_role, if: :new_record?

  def set_default_role
    self.role ||= :user
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist
  # Change strategy to AllowList
end
