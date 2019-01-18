# frozen_string_literal: true

##
# API for handling requests about a specific object's workflow.
class WorkflowsController < ApplicationController
  def lifecycle
    @objects = WorkflowStep.where(
      repository: params[:repo],
      druid: params[:druid]
    ).where.not(lifecycle: nil)
    @objects = @objects.where(version: current_version) if params['active-only']
  end

  def index
    @processes = WorkflowStep.where(
      repository: params[:repo], druid: params[:druid]
    ).order(:datastream, created_at: :asc).group_by(&:datastream)
  end

  def show
    @processes = WorkflowStep.where(
      repository: params[:repo],
      druid: params[:druid],
      datastream: params[:workflow]
    ).order(:datastream, created_at: :asc).group_by(&:datastream)
    render :index
  end

  def update
    if params['current-status'].present?
      find_step_for_process.update(status: params['current-status'])
    else
      find_step_for_process.update(status: 'completed')
    end
    head :no_content
  end

  def destroy
    @processes = WorkflowStep.where(
      repository: params[:repo],
      druid: params[:druid],
      datastream: params[:workflow],
      version: current_version
    ).destroy_all
    head :no_content
  end

  def archive
    @objects = WorkflowStep.where(
      repository: params[:repository],
      datastream: params[:workflow]
    ).count
  end

  def create
    @workflows = WorkflowParser.new(
      request.body.read,
      druid: params[:druid],
      repository: params[:repo],
      version: current_version
    ).create_workflow_steps
  end

  private

  def find_step_for_process
    WorkflowStep.find_by!(
      repository: params[:repo],
      druid: params[:druid],
      datastream: params[:workflow],
      process: params[:process],
      version: current_version
    )
  end

  def current_version
    client.object(params[:druid]).current_version
  rescue Dor::Services::Client::NotFoundResponse # A 404 error
    1
  end

  def client
    @client ||= Dor::Services::Client.configure(url: Settings.dor_services.url,
                                                username: Settings.dor_services.username,
                                                password: Settings.dor_services.password)
  end
end
