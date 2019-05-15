# frozen_string_literal: true

# Service for add workflow steps to Resqueue queues
class QueueService
  # Enqueue the provided step
  # @param [WorkflowStep] workflow step to enqueue
  def self.enqueue(step)
    QueueService.new(step).enqueue
  end

  attr_reader :step

  # @param [WorkflowStep] workflow step to enqueue
  def initialize(step)
    @step = step
  end

  # Enqueue the provided step
  def enqueue
    # Perform the enqueue to Resque
    Resque.enqueue_to(queue_name.to_sym, class_name, step.druid)
    Rails.logger.info "Enqueued #{class_name} for #{step.druid} to #{queue_name}"

    # Update status
    step.update(status: 'queued')
  end

  private

  # @example
  #     => dor:assemblyWF:jp2-create
  def step_name
    @step_name ||= "#{step.repository}:#{step.workflow}:#{step.process}"
  end

  # Generate the queue name from step
  #
  # @example
  #     => 'dor_assemblyWF_jp2-create_default'
  #     => 'dor_assemblyWF_jp2-create_mylane'
  def queue_name
    @queue_name ||= "#{step.repository}_#{step.workflow}_#{step.process}_#{step.lane_id}"
  end

  # Converts a given step to the Robot class name
  # Based on https://github.com/sul-dlss/lyber-core/blob/master/lib/lyber_core/robot.rb#L33
  # @example
  #     => 'Robots::DorRepo::Assembly::Jp2Create'
  def class_name
    @class_name ||= begin
      repo = step.repository.camelize
      workflow = step.workflow.sub('WF', '').camelize
      process = step.process.tr('-', '_').camelize
      "Robots::#{repo}Repo::#{workflow}::#{process}"
    end
  end
end
