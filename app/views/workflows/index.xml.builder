# frozen_string_literal: true

xml.workflows(objectId: params[:druid]) do
  @workflow_steps.each do |workflow_step|
    workflow = workflow_step[0]
    processes = workflow_step[1]

    xml.workflow(repository: params[:repo], objectId: params[:druid], id: workflow) do
      render(partial: 'process', collection: processes, locals: { builder: xml })
    end
  end
end
