# frozen_string_literal: true

##
# Parsing Workflow XML
class WorkflowCreator
  attr_reader :parser, :druid, :repository

  ##
  # @param [WorkflowParser] parser
  # @param [String] druid
  # @param [String] repository
  def initialize(parser:, druid:, repository:)
    @parser = parser
    @druid = druid
    @repository = repository
  end

  ##
  # Delete all the rows for this druid/version/workflow, and replace with new rows.
  # @return [Array]
  def create_workflow_steps
    ActiveRecord::Base.transaction do
      WorkflowStep.where(workflow: workflow_id, druid: druid, version: version).destroy_all

      # Any steps for this object/workflow that are not the current version are marked as not active.
      WorkflowStep.where(workflow: workflow_id, druid: druid).update(active_version: false)

      processes.map do |process|
        WorkflowStep.create(workflow_attributes(process))
      end
    end
  end

  private

  delegate :processes, :workflow_id, to: :parser

  def workflow_attributes(process)
    {
      workflow: workflow_id,
      druid: druid,
      process: process.process,
      status: process.status,
      lane_id: process.lane_id,
      repository: repository,
      lifecycle: process.lifecycle,
      version: version,
      active_version: true
    }
  end

  def version
    @version ||= ObjectVersionService.current_version(druid)
  end
end
