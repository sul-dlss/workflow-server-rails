# frozen_string_literal: true

# Represents a version of a digital object.
# All workflow steps occur on to a particular version.
class Version
  def initialize(druid:, version:, repository:)
    @druid = druid
    @version_id = version
    @repository = repository
  end

  attr_reader :druid, :version_id, :repository

  # @return [ActiveRecord::Relationship] an ActiveRecord scope that has the WorkflowSteps for this version
  def workflow_steps
    WorkflowStep.where(druid: druid, version: version_id, repository: repository)
  end
end
