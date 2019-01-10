# frozen_string_literal: true

xml.workflows(objectId: params[:druid]) do
  @processes.each do |datastream|
    xml.workflow(repository: params[:repo], objectId: params[:druid], id: datastream[0]) do
      datastream[1].each do |workflow|
        workflow.as_process(xml)
      end
    end
  end
end
