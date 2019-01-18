# frozen_string_literal: true

##
# API for handling workflow queue requests.
class WorkflowQueuesController < ApplicationController
  def lane_ids
    @lanes = workflows_for_step_and_status(params[:step], 'waiting').distinct.pluck('lane_id')
  end

  # Used by the robot-sweeper cron job:
  # https://github.com/sul-dlss/robot-master/blob/master/bin/robot-sweeper
  def all_queued
    @workflow_steps = WorkflowStep.where(repository: params[:repository],
                                         status: 'queued').limit(params[:limit])

    return unless hours_ago

    @workflow_steps = @workflow_steps.where(hours_ago)
  end

  # Used by robot-master:
  # https://github.com/sul-dlss/robot-master/blob/master/lib/robot-master/workflow.rb#L169
  def show
    waiting_scope = workflows_for_step_and_status(params[:waiting], 'waiting')
                    .select(:druid)
    waiting_scope = waiting_scope.where(lane_id: params['lane-id']) if params['lane-id']

    scopes = [waiting_scope] + completed_step_scopes
    # Get the druids that belong in all (intersection) of the scopes (ActiveRecord::Relations)
    @objects = WorkflowStep.find_by_sql(*IntersectQuery.intersect(scopes)).pluck(:druid)
  end

  private

  def workflows_for_step_and_status(step, status)
    repository, datastream, process = step.split(':')

    WorkflowStep.where(
      repository: repository,
      datastream: datastream,
      process: process,
      status: status
    )
  end

  # Because `completed` can have more than one value, we can't use the rails params parser.
  def completed_steps
    request.query_string.split('&').grep(/^completed=/).map { |v| v.split('=').last }
  end

  def completed_step_scopes
    completed_steps.map do |step|
      workflows_for_step_and_status(step, 'completed').select('druid')
    end
  end

  def hours_ago
    return unless params['hours-ago']

    hours_ago = params['hours-ago'].to_i.hours.ago
    WorkflowStep.arel_table[:updated_at].lt(hours_ago)
  end
end
