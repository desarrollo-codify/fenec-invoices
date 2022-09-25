class AddPageSizeToCompany < ActiveRecord::Migration[7.0]
  def change
    add_reference :companies, :page_size, foreign_key: true
  end
end
