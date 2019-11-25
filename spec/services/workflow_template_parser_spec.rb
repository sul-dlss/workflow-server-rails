# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkflowTemplateParser do
  let(:xml) { WorkflowTemplateLoader.load_as_xml('accessionWF', 'dor') }
  let(:wf_parser) do
    described_class.new(xml)
  end

  describe '#repo' do
    subject(:repo) { wf_parser.repo }

    it { is_expected.to eq 'dor' }

    context 'when the data is missing a repo' do
      let(:xml) do
        Nokogiri::XML(
          <<~XML
            <?xml version="1.0"?>
            <workflow />
          XML
        )
      end
      it 'raises an error' do
        expect do
          repo
        end.to raise_error(DataError)
      end
    end
  end

  describe '#processes' do
    subject(:processes) { wf_parser.processes }

    it 'returns a list of process structs' do
      expect(processes.length).to eq 16
      expect(processes).to all(be_an_instance_of(WorkflowTemplateParser::Process))
    end
  end
end
