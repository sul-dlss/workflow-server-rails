# frozen_string_literal: true

builder.workflow(repository: workflow.repository, objectId: workflow.druid, id: workflow.name) do
  render(partial: 'process', collection: workflow.steps, locals: { builder: builder })
end
