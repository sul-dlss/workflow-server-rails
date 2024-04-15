# frozen_string_literal: true

# Represents a version of a digital object with associated metadata.
# All workflow steps occur on to a particular version.
class Version
  def initialize(druid:, version:, metadata: nil)
    @druid = druid
    @version_id = version
    @metadata = metadata # this is metadata as a hash to be stored in the VersionMetadata table
  end

  attr_reader :druid, :version_id, :metadata

  def update_metadata
    # if no metadata is passed in (nil), do nothing
    return unless metadata

    # if metadata is passed in but is empty, delete the version metadata record to clear all metadata
    if metadata.empty?
      VersionMetadata.find_by(druid:, version: version_id)&.destroy
    else # otherwise, create/update the metadata record as json in the database
      version_metadata = VersionMetadata.find_or_create_by(druid:, version: version_id)
      version_metadata.update!(values: metadata.to_json)
    end
  end

  # @return [ActiveRecord::Relationship] an ActiveRecord scope that has the WorkflowSteps for this version
  def workflow_steps(workflow)
    WorkflowStep.where(druid:, version: version_id, workflow:)
  end
end
