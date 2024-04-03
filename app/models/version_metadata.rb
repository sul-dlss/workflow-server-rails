# frozen_string_literal: true

# Models optional metadata that is associated with a druid/version pair for any workflow
class VersionMetadata < ApplicationRecord
  self.primary_keys = :druid, :version
end
