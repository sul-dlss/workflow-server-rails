# frozen_string_literal: true

##
# API for handling requests about a specific object's workflow.
class WorkflowsController < ApplicationController
  # Used by Dor::Workflow::Client::LifecycleRoutes
  # to get lifecycle milestones and object status (e.g. "In accessioning")
  def lifecycle
    steps = WorkflowStep.where(druid: params[:druid])

    return @objects = steps.lifecycle.complete unless params['active-only']

    # Active means that it's of the current version, and that all the steps in
    # the current version haven't been completed yet.
    steps = steps.for_version(params[:version])
    return @objects = [] unless steps.incomplete.any?

    @objects = steps.lifecycle
  end

  # Display all steps for all versions of a given object
  def index
    object_steps = WorkflowStep.where(druid: params[:druid])
                               .order(:workflow, created_at: :asc)
                               .group_by(&:workflow)

    @workflows = object_steps.map do |wf_name, workflow_steps|
      Workflow.new(name: wf_name,
                   druid: params[:druid],
                   steps: workflow_steps)
    end
  end

  # Display all steps for one workflow for all versions of a given object
  def show
    workflow_steps = WorkflowStep.where(
      druid: params[:druid],
      workflow: params[:workflow]
    ).order(:workflow, created_at: :asc)
    @workflow = Workflow.new(name: params[:workflow], druid: params[:druid], steps: workflow_steps)
  end

  def destroy
    obj = Version.new(
      druid: params[:druid],
      version: params[:version]
    )
    obj.workflow_steps(params[:workflow]).destroy_all
    head :no_content
  end

  def create
    return render(plain: 'Unknown workflow', status: :bad_request) if template.nil?

    WorkflowCreator.new(
      workflow_id: initial_parser.workflow_id,
      processes: initial_parser.processes,
      version: Version.new(
        druid: params[:druid],
        version: params[:version]
      )
    ).create_workflow_steps

    head :created
  end

  private

  def initial_parser
    @initial_parser ||= begin
      initial_workflow = WorkflowTransformer.initial_workflow(template, params[:'lane-id'])
      InitialWorkflowParser.new(initial_workflow)
    end
  end

  def template_parser
    @template_parser ||= WorkflowTemplateParser.new(template)
  end

  def template
    @template ||= WorkflowTemplateLoader.load_as_xml(params[:workflow])
  end
end
