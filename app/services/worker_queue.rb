# frozen_string_literal: true

# Pushes workflow_step's into the Resque queue so that work can begin
class WorkerQueue
  # @param [ActiveRecord::Relation<WorkflowStep>] steps to enqueue
  def self.enqueue_steps(steps)
    steps.each do |step|
      Resque.enqueue_to queue_name(step), job_name(step), step.druid
    end
  end

  def self.job_name(step)
    [
      'Robots',
      step.repository.camelcase + 'Repo', # 'Dor' conflicts with dor-services
      step.workflow.sub('WF', '').camelcase,
      step.process.tr('-', '_').camelcase
    ].join('::')
  end
  private_class_method :job_name

  def self.queue_name(step)
    [
      step.repository,
      step.workflow,
      step.process,
      'default'
    ].join('_')
  end

  private_class_method :queue_name
end
