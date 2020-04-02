# frozen_string_literal: true

##
# API for handling workflow queue requests.
class WorkflowQueuesController < ApplicationController
  def lane_ids
    @lanes = workflows_for_step_and_scope(params[:step], :waiting).distinct.pluck('lane_id')
  end

  # Used by the robot-sweeper cron job:
  # https://github.com/sul-dlss/robot-master/blob/master/bin/robot-sweeper
  def all_queued
    @workflow_steps = WorkflowStep.where(status: 'queued').limit(params[:limit])

    return unless hours_ago

    @workflow_steps = @workflow_steps.where(hours_ago)
  end

  def show
    if params[:waiting].present?
      # Used by hydra_etd:
      # https://github.com/sul-dlss/hydra_etd/blob/4d19bbbf772cd37c77b7afdf0691966db85d04a3/app/services/cron_base.rb#L10
      find_waiting_objects
    else
      # Used by count_objects_in_step
      # https://github.com/sul-dlss/dor-workflow-service/blob/845edfe4160a165d62b06530138f71e5c816a5c9/lib/dor/services/workflow_service.rb#L499
      # Called from https://github.com/sul-dlss/preservation_robots/blob/659de805d9a5cc04216676060bcc4d48633a5a78/lib/stats_reporter.rb#L78-L79
      find_completed_objects
    end
  end

  private

  def find_waiting_objects
    waiting_scope = workflows_for_step_and_scope(params[:waiting], :waiting)
                    .select(:druid)
    waiting_scope = waiting_scope.where(lane_id: params['lane-id']) if params['lane-id']

    scopes = [waiting_scope] + completed_step_scopes

    # Get the druids that belong in all (intersection) of the scopes (ActiveRecord::Relations)
    @objects = WorkflowStep.find_by_sql(*IntersectQuery.intersect(scopes)).pluck(:druid)
  end

  def find_completed_objects
    @objects = WorkflowStep.where(workflow: params[:workflow],
                                  process: params[:completed],
                                  status: 'completed').pluck(:druid)
  end

  def workflows_for_step_and_scope(step, scope)
    _repository, workflow, process = step.split(':')

    WorkflowStep.active.public_send(scope).where(workflow: workflow, process: process)
  end

  # Because `completed` can have more than one value, we can't use the rails params parser.
  def completed_steps
    request.query_string.split('&').grep(/^completed=/).map { |v| v.split('=').last }.map { |v| CGI.unescape(v) }
  end

  def completed_step_scopes
    completed_steps.map do |step|
      workflows_for_step_and_scope(step, :complete).select(:druid)
    end
  end

  def hours_ago
    return unless params['hours-ago']

    hours_ago = params['hours-ago'].to_i.hours.ago
    WorkflowStep.arel_table[:updated_at].lt(hours_ago)
  end
end
