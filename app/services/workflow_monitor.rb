# frozen_string_literal: true

# Monitors stuck workflows
class WorkflowMonitor
  # Look for "queued" steps that are more than 12 hours old
  # and "started" steps that are more than 24 hours old
  def self.monitor
    new.monitor
  end

  def monitor
    monitor_queued_steps
    monitor_started_steps
  end

  private

  def monitor_started_steps
    steps = WorkflowStep.started
                        .where(WorkflowStep.arel_table[:updated_at].lt(48.hours.ago))
                        .limit(1000)

    steps.each do |step|
      Honeybadger.notify("Workflow step has been running for more than 48 hours: <druid:\"#{step.druid}\" " \
                         "version:\"#{step.version}\" workflow:\"#{step.workflow}\" process:\"#{step.process}\">. " \
                         'Perhaps there is a problem with it.')
    end
  end

  def monitor_queued_steps
    queued = WorkflowStep.queued
                         .where(WorkflowStep.arel_table[:updated_at].lt(24.hours.ago))
    return if queued.count.zero?

    Honeybadger.notify("#{queued.count} workflow steps have been queued for more than 24 hours. Perhaps there is a " \
                       'problem with the robots.', context: { druids: queued.pluck(:druid) })
  end
end
