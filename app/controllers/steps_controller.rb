# frozen_string_literal: true

##
# API for handling requests about a specific step within an object's workflow.
class StepsController < ApplicationController
  # Update a single WorkflowStep
  # If there are next steps, they are enqueued.
  # rubocop:disable Metrics/AbcSize
  def update
    parser = ProcessParser.new(process_from_request_body)
    step = find_or_create_step_for_process

    return render plain: process_mismatch_error(parser), status: :bad_request if parser.process != params[:process]

    return render plain: status_mismatch_error(step), status: :conflict if params['current-status'] && step.status != params['current-status']

    step.update(parser.to_h)

    # Enqueue next steps
    next_steps = NextStepService.for(step: step)
    next_steps.each { |next_step| QueueService.enqueue(next_step) }

    SendUpdateMessage.publish(druid: step.druid)
    render json: { next_steps: next_steps }
  end
  # rubocop:enable Metrics/AbcSize

  def destroy_all
    WorkflowStep.where(druid: params[:druid]).destroy_all
    head :no_content
  end

  def show
    @step = find_step_for_process

    render plain: '', status: :not_found if @step.nil?
  end

  private

  def process_mismatch_error(parser)
    "Process name in body (#{parser.process}) does not match process name in URI (#{params[:process]})"
  end

  def status_mismatch_error(step)
    "Status in params (#{params['current-status']}) does not match current status (#{step.status})"
  end

  # Returns most recent workflow step
  def find_step_for_process
    WorkflowStep.order(version: :desc).find_by(
      repository: params[:repo],
      druid: params[:druid],
      workflow: params[:workflow],
      process: params[:process]
    )
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
    # Providing the version as a param is for local testing without needing to run DOR services.
    params[:version] || ObjectVersionService.current_version(params[:druid])
  end
end
