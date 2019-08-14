# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StepsController do
  let(:repository) { 'dor' }
  let(:client) { instance_double(Dor::Services::Client::Object, version: version_client) }
  let(:version_client) { instance_double(Dor::Services::Client::ObjectVersion, current: '1') }
  let(:druid) { first_step.druid }
  let(:workflow_id) { 'accessionWF' }
  let(:first_step) { FactoryBot.create(:workflow_step, status: 'completed') } # start-accession, which is already completed

  before do
    FactoryBot.create(:workflow_step, druid: druid, process: 'descriptive-metadata')
    FactoryBot.create(:workflow_step, druid: druid, process: 'rights-metadata')
    allow(Dor::Services::Client).to receive(:object).with(druid).and_return(client)
    allow(SendUpdateMessage).to receive(:publish)
    allow(QueueService).to receive(:enqueue)
  end

  describe 'PUT update' do
    context 'when updating a step' do
      let(:body) { '<process name="descriptive-metadata" status="test" />' }

      it 'updates the step' do
        put :update, body: body, params: { repo: repository, druid: druid, workflow: workflow_id,
                                           process: 'descriptive-metadata', format: :xml }
        expect(response.body).to eq('{"next_steps":[]}')
        expect(SendUpdateMessage).to have_received(:publish).with(druid: druid)
        expect(WorkflowStep.find_by(druid: druid, process: 'descriptive-metadata').status).to eq('test')
        expect(QueueService).to_not have_received(:enqueue)
      end

      it 'verifies the current status' do
        put :update, body: body, params: { repo: repository, druid: druid, workflow: workflow_id,
                                           process: 'descriptive-metadata', 'current-status': 'not-waiting',
                                           format: :xml }
        expect(response.body).to eq('Status in params (not-waiting) does not match current status (waiting)')
        expect(response.code).to eq('409')
      end

      it 'verifies that process in url and body match' do
        put :update, body: body, params: { repo: repository, druid: druid, workflow: workflow_id,
                                           process: 'rights-metadata', format: :xml }
        expect(response.body).to eq('Process name in body (descriptive-metadata) does not match process name in URI ' \
                                    '(rights-metadata)')
        expect(response.code).to eq('400')
      end
    end

    context 'when completing a step' do
      let(:body) { '<process name="descriptive-metadata" status="completed" />' }
      it 'updates the step and enqueues next step' do
        put :update, body: body, params: { repo: repository, druid: druid, workflow: workflow_id,
                                           process: 'descriptive-metadata', format: :xml }
        expect(response.body).to match(/rights-metadata/)
        expect(SendUpdateMessage).to have_received(:publish).with(druid: druid)
        expect(WorkflowStep.find_by(druid: druid, process: 'descriptive-metadata').status).to eq('completed')
        expect(QueueService).to have_received(:enqueue).with(WorkflowStep.find_by(druid: druid,
                                                                                  process: 'rights-metadata'))
      end
    end
  end
end
