# frozen_string_literal: true

FactoryBot.define do
  factory :workflow_step do
    sequence :druid do |n|
      "druid:bb123bc#{n.to_s.rjust(4, '0')}" # ensure we always have a valid druid format
    end
    workflow { 'accessionWF' }
    process { 'start-accession' }
    version { 1 }
    lane_id { 'default' }
    status { 'waiting' }

    trait :completed do
      status { 'completed' }
      completed_at { Time.now }
    end

    trait :with_ocr_metadata do
      after(:create) do |step|
        create(:workflow_metadata, druid: step.druid, version: step.version, values: { requireOCR: true })
      end
    end
  end
end
