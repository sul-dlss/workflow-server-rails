# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkflowParser do
  include XmlFixtures

  let(:druid) { 'druid:abc123' }
  let(:repository) { 'dor' }
  let(:wf_parser) do
    described_class.new(workflow_create, druid: druid, repository: repository)
  end

  describe '#create_workflow_steps' do
    it 'creates a WorkflowStep for each process' do
      expect(ObjectVersionService).to receive(:current_version).with(druid).and_return('1')
      expect do
        wf_parser.create_workflow_steps
      end.to change(WorkflowStep, :count)
        .by(Nokogiri::XML(workflow_create).xpath('//process').count)
      expect(WorkflowStep.last.druid).to eq druid
      expect(WorkflowStep.last.repository).to eq repository
    end
  end
end
