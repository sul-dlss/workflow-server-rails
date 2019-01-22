# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Objects for workstep', type: :request do
  context 'with prerequisites' do
    let(:prereqs_and_waiting) do
      FactoryBot.create(:workflow_step,
                        process: 'reset-workspace',
                        status: 'waiting')
    end

    let(:prereqs_and_not_waiting) do
      FactoryBot.create(:workflow_step,
                        process: 'reset-workspace',
                        status: 'queued')
    end

    let(:not_prereqs_and_waiting) do
      FactoryBot.create(:workflow_step,
                        process: 'reset-workspace',
                        status: 'waiting')
    end

    let(:second_prereqs_and_waiting) do
      FactoryBot.create(:workflow_step,
                        process: 'reset-workspace',
                        status: 'waiting')
    end

    let(:prereqs_and_waiting_and_wrong_lane) do
      FactoryBot.create(:workflow_step,
                        process: 'reset-workspace',
                        lane_id: 'fast',
                        status: 'waiting')
    end

    before do
      FactoryBot.create(:workflow_step,
                        druid: prereqs_and_waiting.druid,
                        process: 'sdr-ingest-received',
                        status: 'completed')
      FactoryBot.create(:workflow_step,
                        druid: prereqs_and_waiting.druid,
                        process: 'provenance-metadata',
                        status: 'completed')

      FactoryBot.create(:workflow_step,
                        druid: second_prereqs_and_waiting.druid,
                        process: 'sdr-ingest-received',
                        status: 'completed')
      FactoryBot.create(:workflow_step,
                        druid: second_prereqs_and_waiting.druid,
                        process: 'provenance-metadata',
                        status: 'completed')

      FactoryBot.create(:workflow_step,
                        druid: prereqs_and_waiting_and_wrong_lane.druid,
                        process: 'sdr-ingest-received',
                        status: 'completed')
      FactoryBot.create(:workflow_step,
                        druid: prereqs_and_waiting_and_wrong_lane.druid,
                        process: 'provenance-metadata',
                        status: 'completed')

      FactoryBot.create(:workflow_step,
                        druid: prereqs_and_not_waiting.druid,
                        process: 'sdr-ingest-received',
                        status: 'completed')
      FactoryBot.create(:workflow_step,
                        druid: prereqs_and_not_waiting.druid,
                        process: 'provenance-metadata',
                        status: 'completed')
    end

    it 'shows the items that are waiting and have met the prereqs' do
      get '/workflow_queue?waiting=dor:accessionWF:reset-workspace&' \
          'completed=dor:accessionWF:sdr-ingest-received&' \
          'completed=dor:accessionWF:provenance-metadata&limit=100&lane-id=default'
      expect(response).to render_template(:show)

      expect(response.body).to be_equivalent_to <<~XML
        <objects count="2">
          <object id="#{prereqs_and_waiting.druid}"/>
          <object id="#{second_prereqs_and_waiting.druid}"/>
        </objects>
      XML
    end
  end

  context 'without waiting' do
    let!(:complete) do
      FactoryBot.create(:workflow_step,
                        repository: 'sdr',
                        datastream: 'preservationIngestWF',
                        process: 'complete-ingest',
                        status: 'completed')
    end
    it 'shows the items that have completed' do
      get '/workflow_queue?completed=complete-ingest&' \
          'repository=sdr&workflow=preservationIngestWF'
      expect(response).to render_template(:show)

      expect(response.body).to be_equivalent_to <<~XML
        <objects count="1">
          <object id="#{complete.druid}"/>
        </objects>
      XML
    end
  end

  context 'without prerequisites' do
    let!(:waiting) do
      FactoryBot.create(:workflow_step,
                        datastream: 'versioningWF',
                        process: 'start-accession',
                        status: 'waiting')
    end

    let!(:second_waiting) do
      FactoryBot.create(:workflow_step,
                        datastream: 'versioningWF',
                        process: 'start-accession',
                        status: 'waiting')
    end

    before do
      # It shouldn't show this one because it's the wrong process
      FactoryBot.create(:workflow_step,
                        datastream: 'versioningWF',
                        process: 'submit-version',
                        status: 'waiting')
    end

    it 'shows the items that are waiting' do
      get '/workflow_queue?waiting=dor:versioningWF:start-accession'
      expect(response).to render_template(:show)

      expect(response.body).to be_equivalent_to <<~XML
        <objects count="2">
          <object id="#{waiting.druid}"/>
          <object id="#{second_waiting.druid}"/>
        </objects>
      XML
    end
  end
end
