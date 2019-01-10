# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkflowParser do
  include XmlFixtures

  let(:druid) { 'druid:abc123' }
  let(:repository) { 'dor' }
  let(:wf_parser) { described_class.new(workflow_create, druid, repository) }
  describe '#create_workflows' do
    it 'creates a workflow for each process' do
      expect do
        wf_parser.create_workflow_steps
      end.to change(WorkflowStep, :count)
        .by(Nokogiri::XML(workflow_create).xpath('//process').count)
      expect(WorkflowStep.last.druid).to eq druid
      expect(WorkflowStep.last.repository).to eq repository
    end
  end
end
