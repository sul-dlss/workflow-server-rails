# frozen_string_literal: true

namespace :workflow do
  desc 'Update a workflow step'
  task :step, %i[repo druid workflow process version status] => :environment do |_task, args|
    step = WorkflowStep.find_by(
      repository: args[:repo],
      druid: args[:druid],
      workflow: args[:workflow],
      process: args[:process],
      version: args[:version]
    )

    raise 'Workflow step does not already exist' if step.nil?

    step.status = args[:status]
    step.save
    puts("Setting #{args[:process]} to #{args[:status]}")

    # Enqueue next steps
    next_steps = NextStepService.for(step: step)
    next_steps.each { |next_step| QueueService.enqueue(next_step) }

    SendUpdateMessage.publish(druid: step.druid)
  end
end
