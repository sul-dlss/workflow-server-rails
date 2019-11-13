# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkflowCreator do
  let(:druid) { 'druid:bb123bb1234' }
  let(:xml) do
    workflow_template = WorkflowTemplateLoader.load_as_xml('accessionWF')
    WorkflowTransformer.initial_workflow(workflow_template)
  end
  let(:wf_parser) do
    InitialWorkflowParser.new(xml)
  end

  let(:wf_creator) do
    described_class.new(
      workflow_id: wf_parser.workflow_id,
      processes: wf_parser.processes,
      version: Version.new(druid: druid, version: 1)
    )
  end

  before do
    allow(QueueService).to receive(:enqueue)
  end

  describe '#create_workflow_steps' do
    subject(:create_workflow_steps) { wf_creator.create_workflow_steps }

    it 'creates a WorkflowStep for each process' do
      expect do
        create_workflow_steps
      end.to change(WorkflowStep, :count).by(16)
      expect(WorkflowStep.last.druid).to eq druid
      expect(QueueService).to have_received(:enqueue).with(WorkflowStep.find_by(druid: druid, process: 'descriptive-metadata'))
    end

    context 'when workflow steps already exists' do
      before do
        wf_creator.create_workflow_steps
      end

      it 'replaces them' do
        expect do
          create_workflow_steps
        end.not_to change(WorkflowStep, :count)
        expect(QueueService).to have_received(:enqueue).with(WorkflowStep.find_by(druid: druid, process: 'descriptive-metadata'))
      end
    end
  end
end
