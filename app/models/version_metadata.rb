# frozen_string_literal: true

# Models optional metadata that is associated with a Version (druid/version pair) for any workflow
class VersionMetadata < ApplicationRecord
  self.primary_key = [:druid, :version]
end
