# frozen_string_literal: true

class CreateVersionMetadatas < ActiveRecord::Migration[7.0]
  def change
    create_table :version_metadata, primary_key: %i[druid version] do |t|
      t.string      :druid, null: false, index: true
      t.integer     :version, default: 1
      t.jsonb       :values, default: {}
      t.timestamps
    end

    add_index :version_metadata, %i[druid version]
  end
end
