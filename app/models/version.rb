# frozen_string_literal: true

# Represents a version of a digital object.
# All workflow steps occur on to a particular version.
class Version
  def initialize(druid:, version:, metadata: nil)
    @druid = druid
    @version = version
    @metadata = VersionMetadata.find_or_create_by(druid:, version:)
    @metadata.update(metadata:)
  end

  attr_reader :druid, :version, :metadata

  # @return [ActiveRecord::Relationship] an ActiveRecord scope that has the WorkflowSteps for this version
  def workflow_steps(workflow)
    WorkflowStep.where(druid:, version:, workflow:)
  end
end
