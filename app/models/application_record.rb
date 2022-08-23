# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  VALID_NAME_REGEX = %r{\A[a-zA-Z0-9À-ÿ._ /-]+\z}
  VALID_CITY_REGEX = /\A[a-zA-Z0-9À-ÿ ]+\z/
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
end
