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
    obj = Version.new(repository: params[:repo],
                      druid: params[:druid],
                      version: current_version)
    obj.workflow_steps.where(
      workflow: 'versioningWF',
      process: ['submit-version', 'start-accession']
    )
  end

  def initialize_workflow
    obj = Version.new(repository: params[:repo],
                      druid: params[:druid],
                      version: current_version)

    parser = InitialWorkflowParser.new(initial_workflow)
    WorkflowCreator.new(
      workflow_id: parser.workflow_id,
      processes: parser.processes,
      version: obj
    ).create_workflow_steps
  end

  def current_version
    # Providing the version as a param is for local testing without needing to run DOR services.
    @current_version ||= params[:version] || ObjectVersionService.current_version(params[:druid])
  end

  def initial_workflow
    template = WorkflowTemplateLoader.load_as_xml('accessionWF', 'dor')
    WorkflowTransformer.initial_workflow(template)
  end
end
