# frozen_string_literal: true

class ActiveVersion < ActiveRecord::Migration[5.2]
  def change
    add_column :workflow_steps, :active_version, :boolean, default: false, index: true
    sql = 'UPDATE workflow_steps a SET active_version = true
    FROM (
      SELECT druid, version FROM workflow_steps
      GROUP BY druid, version
      HAVING version = MAX(version)
    ) as b
    WHERE
    a.druid = b.druid AND
    a.version = b.version'
    WorkflowStep.connection.execute(sql)
  end
end
