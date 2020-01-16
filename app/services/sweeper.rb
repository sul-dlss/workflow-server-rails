# frozen_string_literal: true

# Gets stuck workflows moving again by changing things to waiting
class Sweeper
  # Look for "queued" steps that are more than 12 hours old
  def self.sweep
    new.sweep
  end

  def sweep
    steps_to_sweep.each do |step|
      step.update(status: 'waiting')
      notify_honeybadger(step)
      enqueue_next_steps(step)
    end
  end

  private

  def steps_to_sweep
    WorkflowStep.queued
                .where(WorkflowStep.arel_table[:updated_at].lt(12.hours.ago))
                .limit(1000)
  end

  def notify_honeybadger(step)
    Honeybadger.notify("Stale workflow step found: <druid:\"#{step.druid}\" " \
      "version:\"#{step.version}\" workflow:\"#{step.workflow}\" process:\"#{step.process}\">. " \
      'Requeuing it.')
  end

  def enqueue_next_steps(step)
    NextStepService.for(step: step).each { |next_step| QueueService.enqueue(next_step) }
  end
end
