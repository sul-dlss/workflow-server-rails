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
    find_next(step: step)
  end

  private

  # @param [WorkflowStep] step
  # @return [ActiveRecord::Relation] a list of WorkflowSteps
  def find_next(step:) # rubocop:disable Metrics/AbcSize
    steps = Version.new(druid: step.druid, version: step.version).workflow_steps

    completed_steps = steps.complete.pluck(:process)

    # Find workflow/version/steps and subtract what we've completed so far.
    todo = workflow(step.workflow).except(*completed_steps)

    # Now filter by the steps that we have the prerequisites done for:
    ready = todo.select { |_, process| (process.prerequisites - completed_steps).empty? && !process.skip_queue }.keys

    results = WorkflowStep.transaction do
      set = steps.waiting.lock.where(process: ready)
      results_before_update = set.to_a
      set.update_all(status: 'queued')
      results_before_update
    end

    # We mustn't enqueue steps before the transaction completes, otherwise the workers
    # could start working on it and find it to still be "waiting".
    results.each { |next_step| QueueService.enqueue(next_step) }
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
