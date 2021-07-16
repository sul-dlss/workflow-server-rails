# frozen_string_literal: true

# Service for add workflow steps to Resqueue queues
class QueueService
  # Enqueue the provided step
  # NOTE: This should only be called by one process at a time. Wrap this in a database row lock.
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
  # NOTE: This should only be called by one process at a time. Wrap this in a database row lock.
  def enqueue
    # Update status
    step.update(status: 'queued')

    # .enqueue_to will return false if a pre-queue hook prevented it from queueing.
    # Don't necessarily expect this to occur, but want to prevent from failing silently.
    raise "Enqueueing #{class_name} for #{step.druid} to #{queue_name} failed." unless Resque.enqueue_to(queue_name, class_name, step.druid)

    Rails.logger.info "Enqueued #{class_name} for #{step.druid} to #{queue_name}"
  end

  private

  # Generate the queue name from step
  #
  # @example
  #     => 'assemblyWF_default'
  #     => 'assemblyWF_low'
  def queue_name
    @queue_name ||= if class_name == 'Robots::DorRepo::Assembly::Jp2Create'
                      # Special case because this robot can eats up too much memory if more
                      # than one instance is running on a worker box simultaneously
                      'assemblyWF_jp2'
                    else
                      "#{step.workflow}_#{step.lane_id}"
                    end
  end

  # Converts a given step to the Robot class name
  # Based on https://github.com/sul-dlss/lyber-core/blob/master/lib/lyber_core/robot.rb#L33
  # @example
  #     => 'Robots::DorRepo::Assembly::Jp2Create'
  def class_name
    @class_name ||= begin
      repo = %w[preservationIngestWF sdrIngestWF].include?(step.workflow) ? 'Sdr' : 'Dor'
      workflow = step.workflow.sub('WF', '').camelize
      process = step.process.tr('-', '_').camelize
      "Robots::#{repo}Repo::#{workflow}::#{process}"
    end
  end
end
