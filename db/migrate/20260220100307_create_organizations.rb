class CreateOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :organizations do |t|
      t.string :name
      t.text :description
      t.string :industry
      t.string :website
      t.boolean :active

      t.timestamps
    end
    add_index :organizations, :name
  end
end
