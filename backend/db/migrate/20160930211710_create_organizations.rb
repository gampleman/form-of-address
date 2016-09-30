class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :address
      t.timestamps
    end

    create_table :persons do |t| # let's make life easy with AR
      t.string :name
      t.string :email
      t.string :phone
      t.string :address

      t.integer :organization_id
      t.timestamps
    end

    add_index :persons, :organization_id
  end
end
