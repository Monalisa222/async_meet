class AllowNullAssignedUserInTasks < ActiveRecord::Migration[8.1]
  def change
    change_column_null :tasks, :assigned_user_id, true
  end
end
