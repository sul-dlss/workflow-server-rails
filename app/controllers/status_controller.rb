# frozen_string_literal: true

##
# API for handling requests about the state of all objects in a workflow
class StatusController < ApplicationController
  def show
    workflow_name = params.require(:workflow)
    @result = status_response(workflow_name)

    render json: { steps: @result }
  end

  private

  def status_response(workflow_name)
    tree = steps_for_workflow(workflow_name)
    xml = WorkflowTemplateService.template_for(workflow_name)
    processes = WorkflowParser.new(xml).processes
    step_names = processes.map(&:process)
    step_names.map do |process_name|
      { name: process_name, object_status: tree.fetch(process_name, {}) }
    end
  end

  # Returns a hash of counts of objects in each step and status:
  # @example
  #  {"start-accession"=>{"completed"=>1}
  def steps_for_workflow(workflow)
    counts = WorkflowStep.active.where(workflow: workflow).group(:process, :status).count
    {}.tap do |tree|
      counts.each do |(step, status), val|
        tree[step] ||= {}
        tree[step][status] = val
      end
    end
  end
end
