# frozen_string_literal: true

xml.workflows(objectId: params[:druid]) do
  @workflow_steps.each do |workflow_step|
    workflow = workflow_step[0]
    processes = workflow_step[1]

    xml.workflow(repository: params[:repo], objectId: params[:druid], id: workflow) do
      processes.each do |process|
        process.as_process(xml)
      end
    end
  end
end
