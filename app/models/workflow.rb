# frozen_string_literal: true

# This represents workflow for a particular object
class Workflow
  # @param name [String] the name of the workflow (e.g. 'accessionWF')
  # @param druid [String] the identifier for the object
  # @param steps [Array<WorkflowStep>] the steps that belong to this workflow
  def initialize(name:, druid:, steps: [])
    @name = name
    @druid = druid
    @steps = steps
  end

  attr_reader :name, :druid, :steps
end
