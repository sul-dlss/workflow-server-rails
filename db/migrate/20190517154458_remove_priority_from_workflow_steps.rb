# frozen_string_literal: true

class RemovePriorityFromWorkflowSteps < ActiveRecord::Migration[5.2]
  def change
    remove_column :workflow_steps, :priority
  end
end
