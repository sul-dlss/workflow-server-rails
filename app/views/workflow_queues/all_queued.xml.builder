# frozen_string_literal: true

xml.workflows do
  @workflow_steps.each do |step|
    xml.workflow(name: step.workflow, process: step.process, druid: step.druid, laneId: step.lane_id)
  end
end
