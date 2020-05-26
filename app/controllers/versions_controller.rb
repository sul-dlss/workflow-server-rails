# frozen_string_literal: true

##
# API for handling requests about a specific object's versions.
class VersionsController < ApplicationController
  def close
    update_versioning_steps
    initialize_workflow unless params['create-accession'] == 'false'
    head :ok
  end

  private

  def update_versioning_steps
    find_versioning_steps.update_all(
      attempts: 1,
      status: 'completed'
    )
  end

  def find_versioning_steps
    obj = Version.new(druid: params[:druid],
                      version: params[:version])
    obj.workflow_steps.where(
      workflow: 'versioningWF',
      process: %w[submit-version start-accession]
    )
  end

  def initialize_workflow
    obj = Version.new(druid: params[:druid],
                      version: params[:version])

    parser = InitialWorkflowParser.new(initial_workflow)
    WorkflowCreator.new(
      workflow_id: parser.workflow_id,
      processes: parser.processes,
      version: obj
    ).create_workflow_steps
  end

  def initial_workflow
    template = WorkflowTemplateLoader.load_as_xml('accessionWF')
    WorkflowTransformer.initial_workflow(template)
  end
end
