# frozen_string_literal: true

##
# Parsing workflow template
class WorkflowTemplateParser
  attr_reader :workflow_doc

  # @param [Nokogiri::XML::Document] Workflow template as XML
  def initialize(workflow_doc)
    @workflow_doc = workflow_doc
  end

  # @return [String] the repository
  def repo
    @repo ||= begin
      node = workflow.attr('repository')
      raise DataError, 'Workflow did not provide a required @repository attribute' unless node

      node.value
    end
  end

  private

  def workflow
    workflow_doc.xpath('//workflow-def')
  end
end
