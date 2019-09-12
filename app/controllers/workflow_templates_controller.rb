# frozen_string_literal: true

# Returns a representation of the workflow workflow_templates
# This is used by argo so it can display the progress of an object
# through the workflow.
class WorkflowTemplatesController < ApplicationController
  def show
    template = WorkflowTemplateLoader.load_as_xml(params[:id])
    parser = WorkflowTemplateParser.new(template)
    @processes = parser.processes
  end
end
