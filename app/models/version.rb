# frozen_string_literal: true

# Represents a version of a digital object with associated metadata.
# All workflow steps occur on to a particular version.
class Version
  def initialize(druid:, version:, metadata: nil)
    @druid = druid
    @version_id = version
    @metadata = metadata
  end

  attr_reader :druid, :version_id, :metadata

  def update_metadata
    version_metadata = VersionMetadata.find_or_create_by(druid:, version: version_id)
    version_metadata.update!(values: metadata)
  end

  # @return [ActiveRecord::Relationship] an ActiveRecord scope that has the WorkflowSteps for this version
  def workflow_steps(workflow)
    WorkflowStep.where(druid:, version: version_id, workflow:)
  end
end
