# frozen_string_literal: true

##
# API for handling workflow queue requests.
class WorkflowQueuesController < ApplicationController
  def lane_ids
    repository, datastream, process = params[:step].split(':')
    @lanes = WorkflowStep.where(repository: repository,
                                datastream: datastream,
                                process: process,
                                status: 'waiting').distinct.pluck('lane_id')
  end

  # Used by the robot-sweeper cron job:
  # https://github.com/sul-dlss/robot-master/blob/master/bin/robot-sweeper
  def all_queued
    @workflow_steps = WorkflowStep.where(repository: params[:repository],
                                         status: 'queued').limit(params[:limit])

    return unless hours_ago

    @workflow_steps = @workflow_steps.where(hours_ago)
  end

  private

  def hours_ago
    return unless params['hours-ago']

    hours_ago = params['hours-ago'].to_i.hours.ago
    WorkflowStep.arel_table[:updated_at].lt(hours_ago)
  end
end
