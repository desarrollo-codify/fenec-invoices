# frozen_string_literal: true

class CreateJoinTableUserPageOption < ActiveRecord::Migration[7.0]
  def change
    create_join_table :users, :page_options
  end
end
