class CreateMeetings < ActiveRecord::Migration[8.1]
  def change
    create_table :meetings do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.string :title
      t.text :description
      t.datetime :scheduled_at
      t.integer :status, null: false, default: 0
      t.string :meeting_url
      t.integer :duration_minutes

      t.timestamps
    end

    add_index :meetings, :scheduled_at
  end
end
