# frozen_string_literal: true

##
# Parsing Workflow XML
class WorkflowParser
  attr_reader :xml_request

  ##
  # @param [String] request_body
  def initialize(request_body)
    @xml_request = Nokogiri::XML(request_body)
  end

  # @return [Array<ProcessParser>] a parser for each process element
  def processes
    workflow.xpath('//process').map do |process|
      ProcessParser.new(process)
    end
  end

  # @return [String] the workflow identifier
  def workflow_id
    @workflow_id ||= begin
      node = workflow.attr('id')
      raise DataError, 'Workflow did not provide a required @id attribute' unless node

      node.value
    end
  end

  private

  def workflow
    xml_request.xpath('//workflow')
  end
end
