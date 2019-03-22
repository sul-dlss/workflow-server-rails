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
    WorkflowStep.where(
      repository: params[:repo],
      druid: params[:druid],
      workflow: 'versioningWF',
      process: ['submit-version', 'start-accession'],
      version: current_version
    )
  end

  def initialize_workflow
    WorkflowCreator.new(
      parser: WorkflowParser.new(initial_workflow),
      druid: params[:druid],
      repository: params[:repo],
      version: current_version
    ).create_workflow_steps
  end

  def current_version
    ObjectVersionService.current_version(params[:druid])
  end

  def initial_workflow
    client.workflows.initial(name: 'accessionWF')
  end

  def client
    @client ||= Dor::Services::Client.configure(url: Settings.dor_services.url,
                                                username: Settings.dor_services.username,
                                                password: Settings.dor_services.password)
  end
end
