# frozen_string_literal: true

# Models optional context that is associated with a druid/version pair for any workflow
class VersionContext < ApplicationRecord
  validates :druid, uniqueness: { scope: :version }
  validates_with DruidValidator
  serialize :context, coder: JSON
end
