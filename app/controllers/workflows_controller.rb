# frozen_string_literal: true

##
# API for handling requests about a specific object's workflow.
class WorkflowsController < ApplicationController
  # Used by Dor::VersionService and Dor::StatusService
  # to get lifecycle milestones
  def lifecycle
    steps = WorkflowStep.where(
      repository: params[:repo],
      druid: params[:druid]
    )

    return @objects = steps.lifecycle.complete unless params['active-only']

    # Active means that it's of the current version, and that all the steps in
    # the current version haven't been completed yet.
    steps = steps.for_version(current_version)
    return @objects = [] unless steps.incomplete.any?

    @objects = steps.lifecycle
  end

  def index
    @workflow_steps = WorkflowStep.where(
      repository: params[:repo],
      druid: params[:druid]
    ).order(:workflow, created_at: :asc).group_by(&:workflow)
  end

  def show
    @workflow_steps = WorkflowStep.where(
      repository: params[:repo],
      druid: params[:druid],
      workflow: params[:workflow]
    ).order(:workflow, created_at: :asc).group_by(&:workflow)
  end

  # Update a single WorkflowStep
  def update
    parser = ProcessParser.new(process_from_request_body)
    step = find_or_create_step_for_process

    return render plain: process_mismatch_error(parser), status: :bad_request if parser.process != params[:process]

    return render plain: status_mismatch_error(step), status: :conflict if params['current-status'] && step.status != params['current-status']

    step.update(parser.to_h)
    SendUpdateMessage.publish(druid: step.druid)
    head :no_content
  end

  def destroy
    @workflow_steps = WorkflowStep.where(
      repository: params[:repo],
      druid: params[:druid],
      workflow: params[:workflow],
      version: current_version
    ).destroy_all
    head :no_content
  end

  def archive
    @objects = WorkflowStep.where(
      repository: params[:repository],
      workflow: params[:workflow]
    ).count
  end

  def create
    WorkflowCreator.new(
      parser: WorkflowParser.new(request.body.read),
      druid: params[:druid],
      repository: params[:repo],
      version: current_version
    ).create_workflow_steps
    SendUpdateMessage.publish(druid: params[:druid])
  end

  private

  def process_mismatch_error(parser)
    "Process name in body (#{parser.process}) does not match process name in URI (#{params[:process]})"
  end

  def status_mismatch_error(step)
    "Status in params (#{params['current-status']}) does not match current status (#{step.status})"
  end

  # Only Hydrus calls this when the objects don't exist.
  # I suspect we could make Hydrus behave more "as expected", but for now it's
  # easier to just mirror the behavior of the old Java workflow service - Justin C., Jan 2019
  def find_or_create_step_for_process
    WorkflowStep.find_or_create_by(
      repository: params[:repo],
      druid: params[:druid],
      workflow: params[:workflow],
      process: params[:process],
      version: current_version
    )
  end

  def process_from_request_body
    # TODO: Confirm we do not have a use case for multiple processes when PUT'ing updates
    Nokogiri::XML(request.body.read).xpath('//process').first
  end

  def current_version
    ObjectVersionService.current_version(params[:druid])
  end
end
