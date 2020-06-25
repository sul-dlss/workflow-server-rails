# frozen_string_literal: true

##
# API for handling requests about a specific step within an object's workflow.
class StepsController < ApplicationController
  # Update a single WorkflowStep
  # If there are next steps, they are enqueued.
  # rubocop:disable Metrics/AbcSize
  def update
    parser = ProcessParser.new(process_from_request_body, use_default_lane_id: false)
    step = find_step_for_process

    return render plain: '', status: :not_found if step.nil?

    return render plain: process_mismatch_error(parser), status: :bad_request if parser.process != params[:process]

    return render plain: status_mismatch_error(step), status: :conflict if params['current-status'] && step.status != params['current-status']

    Honeybadger.notify('There is no need to pass "repo" parameter to update a workflow step.') if params[:repo]

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

  def step_not_found_error
    "#{params[:process]} step for #{params[:druid]} not found"
  end

  # Returns most recent workflow step
  # rubocop:disable Metrics/AbcSize
  def find_step_for_process
    query = WorkflowStep.where(druid: params[:druid],
                               workflow: params[:workflow],
                               process: params[:process])
                        .order(version: :desc)
    # Validate uniqueness until https://github.com/sul-dlss/workflow-server-rails/pull/40 is in place
    if query.size != query.pluck(:version).uniq.size
      raise "Duplicate workflow step for #{params[:druid]} #{params[:workflow]} #{params[:process]}"
    end

    query.first
  end
  # rubocop:enable Metrics/AbcSize

  def process_from_request_body
    # TODO: Confirm we do not have a use case for multiple processes when PUT'ing updates
    Nokogiri::XML(request.body.read).xpath('//process').first
  end
end
