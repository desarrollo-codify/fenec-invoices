class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  VALID_NAME_REGEX = /\A[a-zA-Z0-9À-ÿ._ -]+\z/
  VALID_CITY_REGEX = /\A[a-zA-Z0-9À-ÿ ]+\z/
end
