# frozen_string_literal: true

xml.workflows(objectId: params[:druid]) do
  render(partial: 'workflow', collection: @workflows, locals: { builder: xml })
end
