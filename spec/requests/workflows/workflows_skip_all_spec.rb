# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Skip all in a workflow' do
  let(:wf) { FactoryBot.create(:workflow_step) }
  let(:druid) { wf.druid }
  let(:workflow_template) { WorkflowTemplateLoader.load_as_xml('accessionWF') }

  before do
    allow(QueueService).to receive(:enqueue)
  end

  describe 'POST skip_all' do
    let(:druid) { 'druid:bb123bb1234' }
    let(:workflow) { 'accessionWF' }

    let(:headers) { { 'Content-Type' => 'application/xml' } }
    let(:xml_content) { '<?xml version="1.0"?><process name="skip-all" note="note"/>' }

    context 'when skip workflow is called' do
      it 'skips all steps in a workflow' do
        # create workflow steps
        post "/objects/#{druid}/workflows/#{workflow}?version=1"
        # skip all steps
        post("/objects/#{druid}/workflows/#{workflow}/skip-all", params: xml_content, headers:)
        expect(WorkflowStep.all.map(&:status).uniq).to eq(['skipped'])
      end
    end
  end
end
