# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkflowTransformer do
  let(:transformer) { described_class.new workflow_template }

  let(:workflow_template) { WorkflowTemplateLoader.load_as_xml('accessionWF') }

  context '#initial_workflow' do
    it 'transforms to initial workflow' do
      expect(transformer.initial_workflow.to_s).to be_equivalent_to <<~XML
        <?xml version="1.0"?>
        <workflow id="accessionWF">
          <process name="start-accession" status="completed" attempts="1" lifecycle="submitted"/>
          <process name="descriptive-metadata" status="waiting" lifecycle="described"/>
          <process name="rights-metadata" status="waiting"/>
          <process name="content-metadata" status="waiting"/>
          <process name="technical-metadata" status="waiting"/>
          <process name="remediate-object" status="waiting"/>
          <process name="shelve" status="waiting"/>
          <process name="publish" status="waiting" lifecycle="published"/>
          <process name="update-doi" status="waiting"/>
          <process name="provenance-metadata" status="waiting"/>
          <process name="sdr-ingest-transfer" status="waiting"/>
          <process name="sdr-ingest-received" status="waiting" lifecycle="deposited"/>
          <process name="reset-workspace" status="waiting"/>
          <process name="end-accession" status="waiting" lifecycle="accessioned"/>
        </workflow>
      XML
    end
  end
end
