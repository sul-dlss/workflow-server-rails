# frozen_string_literal: true

FactoryBot.define do
  factory :workflow_step do
    sequence :druid do |n|
      "druid:abc123#{n}"
    end
    datastream { 'accessionWF' }
    process { 'proc' }
    repository { 'dor' }
    version { 1 }
    lane_id { 'default' }
  end
end
