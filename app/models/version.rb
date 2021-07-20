# frozen_string_literal: true

# Represents a version of a digital object.
# All workflow steps occur on to a particular version.
class Version
  def initialize(druid:, version:)
    @druid = druid
    @version_id = version
  end

  attr_reader :druid, :version_id

  # @return [ActiveRecord::Relationship] an ActiveRecord scope that has the WorkflowSteps for this version
  def workflow_steps(workflow)
    WorkflowStep.where(druid: druid, version: version_id, workflow: workflow)
  end
end
