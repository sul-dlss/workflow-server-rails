# frozen_string_literal: true

# Returns a representation of the workflow workflow_templates
# This is used by argo so it can display the progress of an object
# through the workflow.
class WorkflowTemplatesController < ApplicationController
  def show
    loader = WorkflowTemplateLoader.new(params[:id])
    return head :not_found unless loader.exists?

    template = loader.load_as_xml
    parser = WorkflowTemplateParser.new(template)
    @processes = parser.processes
  end

  def index
    files = Dir.glob("#{WorkflowTemplateLoader::WORKFLOWS_DIR}/**/*.xml")
    names = files.map { |file| file.sub(%r{#{WorkflowTemplateLoader::WORKFLOWS_DIR}/[^/]*/([^\/]*).xml}, '\1') }.sort
    render json: names
  end
end
