# frozen_string_literal: true

FactoryBot.define do
  factory :workflow_step do
    druid { 'druid:abc123' }
    datastream { 'ds' }
    process { 'proc' }
    repository { 'dor' }
    version { 1 }
  end
end
