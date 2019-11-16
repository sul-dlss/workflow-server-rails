# frozen_string_literal: true

workflow_props = { objectId: workflow.druid, id: workflow.name }
workflow_props.merge!(repository: workflow.repository) if workflow.repository
builder.workflow(workflow_props) do
  render(partial: 'process', collection: workflow.steps, locals: { builder: builder })
end
