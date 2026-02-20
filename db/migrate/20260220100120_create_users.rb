class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :encrypted_password
      t.boolean :active

      t.timestamps
    end
    add_index :users, :email
  end
end
