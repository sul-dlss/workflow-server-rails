# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkflowCreator do
  include XmlFixtures

  let(:druid) { 'druid:abc123' }
  let(:repository) { 'dor' }
  let(:xml) { initial_workflow }
  let(:wf_parser) do
    InitialWorkflowParser.new(xml)
  end

  let(:wf_creator) do
    described_class.new(
      workflow_id: wf_parser.workflow_id,
      processes: wf_parser.processes,
      version: Version.new(druid: druid,
                           repository: repository,
                           version: 1)
    )
  end

  describe '#create_workflow_steps' do
    subject(:create_workflow_steps) { wf_creator.create_workflow_steps }

    it 'creates a WorkflowStep for each process' do
      expect do
        create_workflow_steps
      end.to change(WorkflowStep, :count).by(13)
      expect(WorkflowStep.last.druid).to eq druid
      expect(WorkflowStep.last.repository).to eq repository
    end

    context 'when workflow steps already exists' do
      before do
        wf_creator.create_workflow_steps
      end

      it 'replaces them' do
        expect do
          create_workflow_steps
        end.not_to change(WorkflowStep, :count)
      end
    end
  end
end
