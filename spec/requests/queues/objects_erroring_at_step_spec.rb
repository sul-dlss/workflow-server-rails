# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Objects erroring at workstep' do
  let(:expected_xml) do
    <<~XML
      <objects count="2">
        <object id="#{errored.druid}"/>
        <object id="#{second_errored.druid}"/>
      </objects>
    XML
  end
  let!(:errored) do
    FactoryBot.create(:workflow_step,
                      workflow: 'preservationIngestWF',
                      process: 'complete-ingest',
                      status: 'error',
                      active_version: true)
  end
  let!(:second_errored) do
    FactoryBot.create(:workflow_step,
                      workflow: 'preservationIngestWF',
                      process: 'complete-ingest',
                      status: 'error',
                      active_version: true)
  end

  before do
    # It shouldn't show this one because it's the wrong process
    FactoryBot.create(:workflow_step,
                      workflow: 'preservationIngestWF',
                      process: 'transfer-object',
                      status: 'error',
                      active_version: true)
  end

  it 'shows the items that are errored' do
    get '/workflow_queue?error=preservationIngestWF%3Acomplete-ingest'

    expect(response.body).to be_equivalent_to expected_xml
  end
end
