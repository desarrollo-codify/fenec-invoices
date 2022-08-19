class DocumentType < ApplicationRecord
    validates :code, presence: true, uniqueness: true
    validates :description, presence: true, format: { with: VALID_NAME_REGEX }

    def bulk_load(activities)
        self.upsert_all(activities, unique_by: :code)
    end
end
