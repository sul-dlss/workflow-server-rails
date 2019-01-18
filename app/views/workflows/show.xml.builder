# frozen_string_literal: true

@processes.each do |datastream|
  xml.workflow(repository: params[:repo], objectId: params[:druid], id: datastream[0]) do
    datastream[1].each do |workflow|
      workflow.as_process(xml)
    end
  end
end
