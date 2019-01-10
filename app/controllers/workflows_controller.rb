# frozen_string_literal: true

##
# API for handling workflow request.
class WorkflowsController < ApplicationController
  def lifecycle
    @objects = WorkflowStep.where(
      repository: params[:repo], druid: params[:druid]
    )
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
    @process = WorkflowStep.find_by!(
      repository: params[:repo],
      druid: params[:druid],
      datastream: params[:workflow],
      process: params[:process]
    )

    if params['current-status'].present?
      @process.update(status: params['current-status'])
    else
      @process.update(status: 'completed')
    end
    head :no_content
  end

  def destroy
    @processes = WorkflowStep.where(
      repository: params[:repo],
      druid: params[:druid],
      datastream: params[:workflow]
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
      request.body.read, params[:druid], params[:repo]
    ).create_workflow_steps
  end
end
