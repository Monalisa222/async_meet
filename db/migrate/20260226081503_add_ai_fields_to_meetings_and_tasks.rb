class AddAiFieldsToMeetingsAndTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :meetings, :transcript, :text
    add_column :meetings, :ai_summary, :text
    add_column :meetings, :ai_processed, :boolean, default: false

    add_column :tasks, :ai_generated, :boolean, default: false
  end
end
