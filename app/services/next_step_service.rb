# frozen_string_literal: true

# Find the next steps in the workflow that are ready to be performed.
class NextStepService
  include Singleton

  # @param [WorkflowStep] step
  def self.for(step:)
    instance.for(step: step)
  end

  def initialize
    @workflows = {}
  end

  # @param [WorkflowStep] step
  # @return [ActiveRecord::Relation] a list of WorkflowSteps
  def for(step:)
    # Look at this workflow/version/steps and find what we've completed so far.
    steps = Version.new(druid: step.druid, version: step.version, repository: step.repository).workflow_steps

    completed_steps = steps.complete.pluck(:process)

    # See if there are any waiting for this workflow/version/steps where
    todo = workflow(step.repository, step.workflow).except(*completed_steps)

    # Now filter by the steps that we have the prerequisites done for:
    ready = todo.select { |_, val| (val[:prerequisites] - completed_steps).empty? && !val[:skip_queue] }.keys

    steps.waiting.where(process: ready)
  end

  private

  def workflow(repository, workflow)
    @workflows[workflow] ||= load_workflow(repository, workflow)
  end

  def load_workflow(repository, workflow)
    doc = File.open(File.join('config', 'workflows', repository, "#{workflow}.xml")) { |f| Nokogiri::XML(f) }
    doc.xpath('/workflow-def/process').each_with_object({}) do |process, obj|
      obj[process['name']] = {
        prerequisites: process.xpath('prereq').map(&:text),
        skip_queue: ActiveModel::Type::Boolean.new.cast(process['skip-queue'])
      }
    end
  end
end
