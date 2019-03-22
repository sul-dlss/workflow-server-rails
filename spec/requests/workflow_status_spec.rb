# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Get the status for a workflow', type: :request do
  include XmlFixtures

  before do
    allow(WorkflowTemplateService).to receive(:template_for).and_return(workflow_create)
  end

  context 'for all workflows' do
    before do
      FactoryBot.create(:workflow_step,
                        status: 'completed',
                        active_version: true)

      FactoryBot.create(:workflow_step,
                        status: 'completed',
                        active_version: true)

      FactoryBot.create(:workflow_step,
                        status: 'waiting',
                        active_version: true)

      FactoryBot.create(:workflow_step,
                        status: 'waiting',
                        active_version: false)

      FactoryBot.create(:workflow_step,
                        status: 'error',
                        process: 'descriptive-metadata',
                        active_version: true)

      FactoryBot.create(:workflow_step,
                        status: 'error',
                        process: 'descriptive-metadata',
                        active_version: true)

      FactoryBot.create(:workflow_step,
                        status: 'waiting',
                        process: 'descriptive-metadata',
                        active_version: true)
    end

    it 'displays the counts' do
      get '/workflow/accessionWF'
      expect(response).to be_successful
      expect(JSON.parse(response.body)).to eq(
        'steps' => [
          { 'name' => 'start-accession',
            'object_status' => { 'completed' => 2, 'waiting' => 1 } },
          { 'name' => 'descriptive-metadata',
            'object_status' => { 'error' => 2, 'waiting' => 1 } },
          { 'name' => 'rights-metadata', 'object_status' => {} },
          { 'name' => 'content-metadata', 'object_status' => {} },
          { 'name' => 'technical-metadata', 'object_status' => {} },
          { 'name' => 'remediate-object', 'object_status' => {} },
          { 'name' => 'shelve', 'object_status' => {} },
          { 'name' => 'publish', 'object_status' => {} },
          { 'name' => 'provenance-metadata', 'object_status' => {} },
          { 'name' => 'sdr-ingest-transfer', 'object_status' => {} },
          { 'name' => 'sdr-ingest-received', 'object_status' => {} },
          { 'name' => 'reset-workspace', 'object_status' => {} },
          { 'name' => 'end-accession', 'object_status' => {} }
        ]
      )
    end
  end
end
