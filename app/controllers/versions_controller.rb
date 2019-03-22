# frozen_string_literal: true

##
# API for handling requests about a specific object's versions.
class VersionsController < ApplicationController
  # TODO: Rather than this controller calling dor-services-app, the
  # dor-services-app could pass in accessionWF when it calls this.
  # Unfortunately some places may be hitting this directly and not via dor-services-app
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
    WorkflowCreator.new(
      parser: WorkflowParser.new(initial_workflow),
      version: obj
    ).create_workflow_steps
  end

  def current_version
    @current_version ||= ObjectVersionService.current_version(params[:druid])
  end

  def initial_workflow
    WorkflowTemplateService.template_for('accessionWF')
  end
end
