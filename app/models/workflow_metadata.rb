# frozen_string_literal: true

# Models optional metadata that is associated with a druid/version pair for any workflow
class WorkflowMetadata < ApplicationRecord
  belongs_to :workflow_step, foreign_key: 'druid', primary_key: 'druid', inverse_of: :workflow_metadata
  validate :only_one_workflow_metadata_per_druid_and_version

  def only_one_workflow_metadata_per_druid_and_version
    return unless WorkflowMetadata.where(druid:, version:).count > 1

    errors.add(:base, 'Only one workflow metadata per druid and version is allowed')
  end
end
