class RenameTable < ActiveRecord::Migration[5.2]
  def change
    rename_table :wfs_rails_workflows, :workflow_steps
  end
end
