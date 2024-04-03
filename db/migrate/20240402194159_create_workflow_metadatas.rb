# frozen_string_literal: true

class CreateWorkflowMetadatas < ActiveRecord::Migration[7.0]
  def change
    create_table :workflow_metadata do |t|
      t.string      :druid, null: false, index: true
      t.integer     :version, default: 1, index: true
      t.jsonb       :values, default: {}
      t.timestamps
    end
  end
end
