# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Start the next workflow step for an object', type: :request do
  let(:client) { instance_double(Dor::Services::Client::Object, current_version: '1') }
  let(:druid) { wf.druid }

  before do
    allow(Dor::Services::Client).to receive(:object).with(druid).and_return(client)
  end

  before do
    allow(SendUpdateMessage).to receive(:publish)
  end

  context 'with XML indicating success' do
    let(:process_xml) do
      '<process name="descriptive-metadata" status="completed" elapsed="3" laneId="default" note="Yay"/>'
    end

    let(:wf) do
      FactoryBot.create(:workflow_step,
                        workflow: 'accessionWF',
                        process: 'descriptive-metadata',
                        status: 'error',
                        error_msg: 'Bang!',
                        lifecycle: 'submitted')
    end

    let!(:next_step) do
      FactoryBot.create(:workflow_step,
                        druid: wf.druid,
                        workflow: wf.workflow,
                        process: 'rights-metadata',
                        status: 'waiting')
    end

    before do
      allow(Resque).to receive(:enqueue_to)
    end

    it 'enqueues a message to start the next step and sets the status to queued' do
      post "/dor/objects/#{druid}/workflows/#{wf.workflow}/#{wf.process}/next", params: process_xml

      wf.reload
      expect(wf.status).to eq 'completed'
      expect(wf.error_msg).to be_nil

      expect(wf.lifecycle).to eq 'submitted'
      json = JSON.parse(response.body)
      expect(json['next_steps']).to eq [JSON.parse(next_step.reload.to_json)]
      expect(SendUpdateMessage).to have_received(:publish).with(druid: wf.druid)
      expect(Resque).to have_received(:enqueue_to)
        .with('dor_accessionWF_rights-metadata_default',
              'Robots::DorRepo::Accession::RightsMetadata',
              wf.druid)

      expect(next_step.status).to eq 'queued'
    end
  end

  context 'with XML indicating failure' do
    let(:process_xml) do
      '<process name="descriptive-metadata" status="error" elapsed="3" laneId="default" note="Yay"/>'
    end

    let(:wf) do
      FactoryBot.create(:workflow_step,
                        workflow: 'accessionWF',
                        process: 'descriptive-metadata',
                        status: 'error',
                        error_msg: 'Bang!',
                        lifecycle: 'submitted')
    end

    let!(:next_step) do
      FactoryBot.create(:workflow_step,
                        druid: wf.druid,
                        workflow: wf.workflow,
                        process: 'rights-metadata',
                        status: 'waiting')
    end

    before do
      allow(Resque).to receive(:enqueue_to)
    end

    it "doesn't enqueue the next step " do
      post "/dor/objects/#{druid}/workflows/#{wf.workflow}/#{wf.process}/next", params: process_xml

      wf.reload
      expect(wf.status).to eq 'error'
      expect(wf.error_msg).to be_nil

      expect(wf.lifecycle).to eq 'submitted'

      expect(response.body).to eq '{"next_steps":[]}'
      expect(SendUpdateMessage).to have_received(:publish).with(druid: wf.druid)
      expect(Resque).not_to have_received(:enqueue_to)
    end
  end

  context 'when the next step does not get enqueued' do
    let(:process_xml) do
      '<process name="sdr-ingest-transfer" status="completed" elapsed="3" laneId="default" note="Yay"/>'
    end

    let(:wf) do
      FactoryBot.create(:workflow_step,
                        workflow: 'accessionWF',
                        process: 'sdr-ingest-transfer',
                        status: 'waiting')
    end

    let!(:next_step) do
      FactoryBot.create(:workflow_step,
                        druid: wf.druid,
                        workflow: wf.workflow,
                        process: 'sdr-ingest-received',
                        status: 'waiting')
    end

    before do
      allow(Resque).to receive(:enqueue_to)
    end

    it "doesn't enqueue the next step " do
      post "/dor/objects/#{druid}/workflows/#{wf.workflow}/#{wf.process}/next", params: process_xml

      wf.reload
      expect(wf.status).to eq 'completed'
      expect(response.body).to eq '{"next_steps":[]}'
      expect(SendUpdateMessage).to have_received(:publish).with(druid: wf.druid)
      expect(Resque).not_to have_received(:enqueue_to)
    end
  end
end
