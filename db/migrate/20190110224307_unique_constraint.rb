# frozen_string_literal: true

class UniqueConstraint < ActiveRecord::Migration[5.2]
  def change
    add_index :workflow_steps,
              %i[druid version datastream process],
              unique: true,
              name: 'uk_workflow_steps'
  end
end
