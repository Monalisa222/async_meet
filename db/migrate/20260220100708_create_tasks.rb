class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :meeting, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true
      t.references :assigned_user, null: false, foreign_key: { to_table: :users }
      t.string :title
      t.text :description
      t.date :due_date
      t.integer :status, null: false, default: 0
      t.integer :priority, null: false, default: 0

      t.timestamps
    end
  end
end
