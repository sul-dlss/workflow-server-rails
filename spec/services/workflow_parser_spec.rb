# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkflowParser do
  include XmlFixtures

  let(:xml) { workflow_create }
  let(:wf_parser) do
    described_class.new(xml)
  end

  describe '#workflow_id' do
    subject(:workflow_id) { wf_parser.workflow_id }

    it { is_expected.to eq 'accessionWF' }

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
          workflow_id
        end.to raise_error(DataError)
      end
    end
  end

  describe '#processes' do
    subject(:processes) { wf_parser.processes }

    it 'is a list of ProcessParsers' do
      expect(processes).to all be_instance_of ProcessParser
      expect(processes.size).to eq 13
    end
  end
end
