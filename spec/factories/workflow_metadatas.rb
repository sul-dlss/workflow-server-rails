# frozen_string_literal: true

FactoryBot.define do
  factory :workflow_metadata do
    sequence :druid do |n|
      "druid:bb123bc#{n.to_s.rjust(4, '0')}" # ensure we always have a valid druid format
    end
    version { 1 }
    values { { requireOCR: true, requireTranscript: true } }

    # created the required workflow_step before creating the workflow_metadata
    before(:create) do |metadata|
      metadata.workflow_step = FactoryBot.create(:workflow_step, druid: metadata.druid, version: metadata.version)
    end
  end
end
