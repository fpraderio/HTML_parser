class AddRedirectColumnToWeb < ActiveRecord::Migration
  def change
    add_column :webs, :redirect, :string
  end
end
