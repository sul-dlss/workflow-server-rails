# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkflowParser do
  include XmlFixtures

  let(:druid) { 'druid:abc123' }
  let(:repository) { 'dor' }
  let(:xml) { workflow_create }
  let(:wf_parser) do
    described_class.new(xml, druid: druid, repository: repository)
  end

  describe '#create_workflow_steps' do
    subject(:create_workflow_steps) { wf_parser.create_workflow_steps }

    before do
      allow(ObjectVersionService).to receive(:current_version).with(druid).and_return('1')
    end

    it 'creates a WorkflowStep for each process' do
      expect do
        create_workflow_steps
      end.to change(WorkflowStep, :count)
        .by(Nokogiri::XML(workflow_create).xpath('//process').count)
      expect(WorkflowStep.last.druid).to eq druid
      expect(WorkflowStep.last.repository).to eq repository
    end

    context 'when workflow steps already exists' do
      before do
        wf_parser.create_workflow_steps
      end

      it 'replaces them' do
        expect do
          create_workflow_steps
        end.not_to change(WorkflowStep, :count)
      end
    end

    context 'when the data is missing an id' do
      let(:xml) do
        <<~XML
          <?xml version="1.0"?>
          <workflow>
            <process name="start-assembly"        priority="80" status="completed" lifecycle="pipelined"/>
            <process name="jp2-create"            priority="80" status="skipped"/>
            <process name="checksum-compute"      priority="80" status="waiting"/>
            <process name="exif-collect"          priority="80" status="waiting"/>
            <process name="accessioning-initiate" priority="80" status="waiting"/>
          </workflow>
        XML
      end
      it 'raises an error' do
        expect do
          create_workflow_steps
        end.to raise_error(DataError)
      end
    end
  end
end
