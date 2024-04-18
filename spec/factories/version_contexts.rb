# frozen_string_literal: true

FactoryBot.define do
  factory :version_context do
    sequence :druid do |n|
      "druid:bb123bc#{n.to_s.rjust(4, '0')}" # ensure we always have a valid druid format
    end
    version { 1 }
    values { { requireOCR: true, requireTranscript: true }.to_json } # values are stores as JSON in the database
  end
end