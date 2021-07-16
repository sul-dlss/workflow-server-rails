# frozen_string_literal: true

# Find the next steps in the workflow that are ready to be performed.
class NextStepService
  include Singleton

  # @param [WorkflowStep] step
  def self.enqueue_next_steps(step:)
    instance.enqueue_next_steps(step: step)
  end

  def initialize
    @workflows = {}
  end

  # @param [WorkflowStep] step
  # @return [ActiveRecord::Relation] a list of WorkflowSteps that have been enqueued
  def enqueue_next_steps(step:)
    next_steps = find_next(step: step)
    next_steps.each { |next_step| QueueService.enqueue(next_step) }
    next_steps
  end

  private

  # @param [WorkflowStep] step
  # @return [ActiveRecord::Relation] a list of WorkflowSteps
  def find_next(step:)
    # Look at this workflow/version/steps and find what we've completed so far.
    steps = Version.new(druid: step.druid, version: step.version).workflow_steps

    completed_steps = steps.complete.pluck(:process)

    # See if there are any waiting for this workflow/version/steps where
    todo = workflow(step.workflow).except(*completed_steps)

    # Now filter by the steps that we have the prerequisites done for:
    ready = todo.select { |_, process| (process.prerequisites - completed_steps).empty? && !process.skip_queue }.keys

    steps.waiting.where(process: ready)
  end

  def workflow(workflow)
    @workflows[workflow] ||= load_workflow(workflow)
  end

  # @return [Hash<Process>]
  def load_workflow(workflow)
    doc = WorkflowTemplateLoader.load_as_xml(workflow)
    raise "Workflow #{workflow} not found" if doc.nil?

    parser = WorkflowTemplateParser.new(doc)
    parser.processes.each_with_object({}) do |process, obj|
      obj[process.name] = process
    end
  end
end
