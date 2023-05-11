# frozen_string_literal: true

# Gets stuck workflows moving again by changing things to waiting
class Sweeper
  # Look for "queued" steps that are more than 12 hours old
  # and "started" steps that are more than 24 hours old
  def self.sweep
    new.sweep
  end

  def sweep
    sweep_steps(queued_steps_to_sweep)
    sweep_steps(started_steps_to_sweep)
  end

  private

  def sweep_steps(steps)
    steps.each do |step|
      step.update(status: 'waiting')
      notify_honeybadger(step)
      enqueue_next_steps(step)
    end
  end

  def queued_steps_to_sweep
    WorkflowStep.queued
                .where(WorkflowStep.arel_table[:updated_at].lt(12.hours.ago))
                .where(active_version: true)
                .limit(1000)
  end

  def started_steps_to_sweep
    WorkflowStep.started
                .where(WorkflowStep.arel_table[:updated_at].lt(24.hours.ago))
                .limit(1000)
  end

  def notify_honeybadger(step)
    Honeybadger.notify("Stale workflow step found with #{step.status} status: <druid:\"#{step.druid}\" " \
                       "version:\"#{step.version}\" workflow:\"#{step.workflow}\" process:\"#{step.process}\">. " \
                       'Requeuing it.')
  end

  def enqueue_next_steps(step)
    NextStepService.enqueue_next_steps(step:)
  end
end
