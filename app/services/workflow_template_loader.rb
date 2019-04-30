# frozen_string_literal: true

##
# Loading workflow templates
class WorkflowTemplateLoader
  # Loads a workflow template from file
  # @param [String] workflow_name name/id of workflow, e.g., accessionWF
  # @param [String] optional repository (sdr or dor). If not provided, will guess.
  # @return [String or nil] the workflow as a string or nil if not found
  def self.load(workflow_name, repository = nil)
    WorkflowTemplateLoader.new(workflow_name, repository).load
  end

  # Loads a workflow template from file as XML
  # @param [String] workflow_name name/id of workflow, e.g., accessionWF
  # @param [String] optional repository (sdr or dor). If not provided, will guess.
  # @return [Nokogiri::XML::Document or nil] the workflow as XML or nil if not found
  def self.load_as_xml(workflow_name, repository = nil)
    WorkflowTemplateLoader.new(workflow_name, repository).load_as_xml
  end

  # @param [String] workflow_name name/id of workflow, e.g., accessionWF
  # @param [String] optional repository (sdr or dor). If not provided, will guess.
  def initialize(workflow_name, repository = nil)
    @workflow_name = workflow_name
    @repository = repository
  end

  # @return [String or nil] the filepath of the workflow file or nil if not found
  def workflow_filepath
    @workflow_filepath ||= begin
      possible_filepaths.each do |filepath|
        return filepath if File.exist?(filepath)
      end
      nil
    end
  end

  # @return [boolean] true if the workflow file is found
  def exists?
    !workflow_filepath.nil?
  end

  # @return [String or nil] contents of the workflow file or nil if not found
  def load
    exists? ? File.read(workflow_filepath) : nil
  end

  # @return [Nokogiri::XML::Document or nil] contents of the workflow file as XML or nil if not found
  def load_as_xml
    exists? ? Nokogiri::XML(load) : nil
  end

  attr_reader :workflow_name, :repository

  private

  def possible_filepaths
    construct_filepath(repository) unless repository.nil?
    [construct_filepath('dor'), construct_filepath('sdr')]
  end

  def construct_filepath(repository)
    "config/workflows/#{repository}/#{workflow_name}.xml"
  end
end
