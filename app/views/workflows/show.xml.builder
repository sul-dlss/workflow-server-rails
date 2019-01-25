# frozen_string_literal: true

@processes.each do |workflow|
  xml.workflow(repository: params[:repo], objectId: params[:druid], id: workflow[0]) do
    workflow[1].each do |workflow|
      workflow.as_process(xml)
    end
  end
end
