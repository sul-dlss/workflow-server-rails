# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkflowTemplateParser do
  include XmlFixtures

  let(:xml) { workflow_template }
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
end
