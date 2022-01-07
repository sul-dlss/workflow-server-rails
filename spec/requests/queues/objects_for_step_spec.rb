# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Objects for workstep', type: :request do
  context 'with prerequisites' do
    context 'when one version' do
      let(:expected_xml) do
        <<~XML
          <objects count="2">
            <object id="#{prereqs_and_waiting.druid}"/>
            <object id="#{second_prereqs_and_waiting.druid}"/>
          </objects>
        XML
      end

      let(:prereqs_and_waiting) do
        FactoryBot.create(:workflow_step,
                          process: 'reset-workspace',
                          status: 'waiting',
                          active_version: true)
      end

      let(:prereqs_and_not_waiting) do
        FactoryBot.create(:workflow_step,
                          process: 'reset-workspace',
                          status: 'queued',
                          active_version: true)
      end

      let(:not_prereqs_and_waiting) do
        FactoryBot.create(:workflow_step,
                          process: 'reset-workspace',
                          status: 'waiting',
                          active_version: true)
      end

      let(:second_prereqs_and_waiting) do
        FactoryBot.create(:workflow_step,
                          process: 'reset-workspace',
                          status: 'waiting',
                          active_version: true)
      end

      let(:prereqs_and_waiting_and_wrong_lane) do
        FactoryBot.create(:workflow_step,
                          process: 'reset-workspace',
                          lane_id: 'fast',
                          status: 'waiting',
                          active_version: true)
      end

      before do
        FactoryBot.create(:workflow_step,
                          druid: prereqs_and_waiting.druid,
                          process: 'sdr-ingest-received',
                          status: 'completed',
                          active_version: true)

        FactoryBot.create(:workflow_step,
                          druid: prereqs_and_waiting.druid,
                          process: 'provenance-metadata',
                          status: 'completed',
                          active_version: true)

        FactoryBot.create(:workflow_step,
                          druid: second_prereqs_and_waiting.druid,
                          process: 'sdr-ingest-received',
                          status: 'completed',
                          active_version: true)

        FactoryBot.create(:workflow_step,
                          druid: second_prereqs_and_waiting.druid,
                          process: 'provenance-metadata',
                          status: 'completed',
                          active_version: true)

        FactoryBot.create(:workflow_step,
                          druid: prereqs_and_waiting_and_wrong_lane.druid,
                          process: 'sdr-ingest-received',
                          status: 'completed',
                          active_version: true)

        FactoryBot.create(:workflow_step,
                          druid: prereqs_and_waiting_and_wrong_lane.druid,
                          process: 'provenance-metadata',
                          status: 'completed',
                          active_version: true)

        FactoryBot.create(:workflow_step,
                          druid: prereqs_and_not_waiting.druid,
                          process: 'sdr-ingest-received',
                          status: 'completed',
                          active_version: true)

        FactoryBot.create(:workflow_step,
                          druid: prereqs_and_not_waiting.druid,
                          process: 'provenance-metadata',
                          status: 'completed',
                          active_version: true)
      end

      context 'with repository-qualified step names' do
        it 'shows the items that are waiting and have met the prereqs' do
          get '/workflow_queue?waiting=dor%3AaccessionWF%3Areset-workspace&' \
              'completed=dor%3AaccessionWF%3Asdr-ingest-received&' \
              'completed=dor%3AaccessionWF%3Aprovenance-metadata&limit=100&lane-id=default'

          expect(response.body).to be_equivalent_to expected_xml
        end
      end

      context 'without repository-qualified step names' do
        it 'shows the items that are waiting and have met the prereqs' do
          get '/workflow_queue?waiting=accessionWF%3Areset-workspace&' \
              'completed=accessionWF%3Asdr-ingest-received&' \
              'completed=accessionWF%3Aprovenance-metadata&limit=100&lane-id=default'

          expect(response.body).to be_equivalent_to expected_xml
        end
      end
    end

    context 'when there are multiple versions' do
      let(:expected_xml) do
        <<~XML
          <objects count="1">
            <object id="#{with_preqs_for_current_version.druid}"/>
          </objects>
        XML
      end

      let(:not_prereqs_current_version) do
        FactoryBot.create(:workflow_step,
                          process: 'rights-metadata',
                          status: 'waiting',
                          version: 2)
      end

      let(:with_preqs_for_current_version) do
        FactoryBot.create(:workflow_step,
                          process: 'rights-metadata',
                          status: 'waiting',
                          active_version: true,
                          version: 2)
      end

      before do
        FactoryBot.create(:workflow_step,
                          druid: not_prereqs_current_version.druid,
                          process: 'rights-metadata',
                          status: 'completed',
                          version: 1)

        FactoryBot.create(:workflow_step,
                          druid: not_prereqs_current_version.druid,
                          process: 'descriptive-metadata',
                          status: 'completed',
                          version: 1)

        FactoryBot.create(:workflow_step,
                          druid: not_prereqs_current_version.druid,
                          process: 'descriptive-metadata',
                          status: 'waiting',
                          active_version: true,
                          version: 2)

        FactoryBot.create(:workflow_step,
                          druid: with_preqs_for_current_version.druid,
                          process: 'rights-metadata',
                          status: 'completed',
                          version: 1)

        FactoryBot.create(:workflow_step,
                          druid: with_preqs_for_current_version.druid,
                          process: 'descriptive-metadata',
                          status: 'completed',
                          version: 1)

        FactoryBot.create(:workflow_step,
                          druid: with_preqs_for_current_version.druid,
                          process: 'descriptive-metadata',
                          status: 'completed',
                          active_version: true,
                          version: 2)
      end

      context 'with repository-qualified step names' do
        it 'only shows items that are complete for the most recent version' do
          get '/workflow_queue?completed=dor:accessionWF:descriptive-metadata&' \
              'waiting=dor:accessionWF:rights-metadata'

          expect(response.body).to be_equivalent_to expected_xml
        end
      end

      context 'without repository-qualified step names' do
        it 'only shows items that are complete for the most recent version' do
          get '/workflow_queue?completed=accessionWF:descriptive-metadata&' \
              'waiting=accessionWF:rights-metadata'

          expect(response.body).to be_equivalent_to expected_xml
        end
      end
    end
  end

  context 'without waiting' do
    let(:expected_xml) do
      <<~XML
        <objects count="1">
          <object id="#{complete.druid}"/>
        </objects>
      XML
    end

    let!(:complete) do
      FactoryBot.create(:workflow_step,
                        workflow: 'preservationIngestWF',
                        process: 'complete-ingest',
                        status: 'completed',
                        active_version: true)
    end

    context 'with repository specified' do
      it 'shows the items that have completed' do
        get '/workflow_queue?completed=complete-ingest&' \
            'repository=sdr&workflow=preservationIngestWF'

        expect(response.body).to be_equivalent_to expected_xml
      end
    end

    context 'without repository specified' do
      it 'shows the items that have completed' do
        get '/workflow_queue?completed=complete-ingest&' \
            'workflow=preservationIngestWF'

        expect(response.body).to be_equivalent_to expected_xml
      end
    end
  end

  context 'without prerequisites' do
    let(:expected_xml) do
      <<~XML
        <objects count="2">
          <object id="#{waiting.druid}"/>
          <object id="#{second_waiting.druid}"/>
        </objects>
      XML
    end

    let!(:waiting) do
      FactoryBot.create(:workflow_step,
                        workflow: 'versioningWF',
                        process: 'start-accession',
                        status: 'waiting',
                        active_version: true)
    end

    let!(:second_waiting) do
      FactoryBot.create(:workflow_step,
                        workflow: 'versioningWF',
                        process: 'start-accession',
                        status: 'waiting',
                        active_version: true)
    end

    before do
      # It shouldn't show this one because it's the wrong process
      FactoryBot.create(:workflow_step,
                        workflow: 'versioningWF',
                        process: 'submit-version',
                        status: 'waiting',
                        active_version: true)
    end

    context 'with repository-qualified step names' do
      it 'shows the items that are waiting' do
        get '/workflow_queue?waiting=dor%3AversioningWF%3Astart-accession'

        expect(response.body).to be_equivalent_to expected_xml
      end
    end

    context 'without repository-qualified step names' do
      it 'shows the items that are waiting' do
        get '/workflow_queue?waiting=versioningWF%3Astart-accession'

        expect(response.body).to be_equivalent_to expected_xml
      end
    end
  end
end
