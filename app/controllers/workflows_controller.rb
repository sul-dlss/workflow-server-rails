# frozen_string_literal: true

##
# API for handling requests about a specific object's workflow.
class WorkflowsController < ApplicationController
  def lifecycle
    steps = WorkflowStep.where(
      repository: params[:repo],
      druid: params[:druid]
    )
    return @objects = steps.lifecycle unless params['active-only']

    # Active means that it's of the current version, and that all the steps in
    # the current version haven't been completed yet.
    steps = steps.for_version(current_version)
    return @objects = [] unless steps.incomplete.any?

    @objects = steps.lifecycle
  end

  def index
    @processes = WorkflowStep.where(
      repository: params[:repo],
      druid: params[:druid]
    ).order(:datastream, created_at: :asc).group_by(&:datastream)
  end

  def show
    @processes = WorkflowStep.where(
      repository: params[:repo],
      druid: params[:druid],
      datastream: params[:workflow]
    ).order(:datastream, created_at: :asc).group_by(&:datastream)
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
    WorkflowParser.new(
      request.body.read,
      druid: params[:druid],
      repository: params[:repo]
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
    ObjectVersionService.current_version(params[:druid])
  end
end
