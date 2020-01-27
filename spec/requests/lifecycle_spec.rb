# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Lifecycle', type: :request do
  let(:xml) { Nokogiri::XML(response.body) }
  let(:returned_milestones) { xml.xpath('//lifecycle/milestone') }
  let(:returned_milestone_versions) { returned_milestones.map { |node| node.attr('version') } }
  let(:returned_milestone_text) { returned_milestones.map(&:text) }
  let(:client) { instance_double(Dor::Services::Client::Object, version: version_client) }
  let(:version_client) { instance_double(Dor::Services::Client::ObjectVersion, current: '2') }
  let(:druid) { wf.druid }

  context 'when active-only is set' do
    let(:wf) do
      # This should not appear in the results if they want active-only
      FactoryBot.create(:workflow_step,
                        process: 'start-accession',
                        version: 1,
                        status: 'waiting',
                        lifecycle: 'submitted')
    end

    context 'and all steps in the current version are complete' do
      before do
        FactoryBot.create(:workflow_step,
                          druid: druid,
                          version: 2,
                          process: 'start-accession',
                          status: 'completed',
                          lifecycle: 'submitted')

        # This is not a lifecycle event, so it shouldn't display.
        FactoryBot.create(:workflow_step,
                          druid: druid,
                          version: 2,
                          process: 'remediate-object',
                          status: 'completed')
        allow(Dor::Services::Client).to receive(:object).with(druid).and_return(client)
      end

      context 'when version is not passed (deprecated)' do
        it 'draws an empty set of milestones and notifies honeybadger' do
          expect(Honeybadger).to receive(:notify)
          get "/dor/objects/#{druid}/lifecycle?active-only=true"
          expect(returned_milestone_versions).to eq []
        end
      end

      context 'when version is passed' do
        it 'draws an empty set of milestones' do
          get "/dor/objects/#{druid}/lifecycle?active-only=true&version=2"
          expect(returned_milestone_versions).to eq []
        end
      end
    end

    context 'some steps in the current version are not complete' do
      before do
        FactoryBot.create(:workflow_step,
                          druid: druid,
                          version: 2,
                          process: 'start-accession',
                          status: 'completed',
                          lifecycle: 'submitted')

        # This is not a lifecycle event, so it shouldn't display.
        FactoryBot.create(:workflow_step,
                          druid: druid,
                          version: 2,
                          process: 'remediate-object',
                          status: 'waiting')
        allow(Dor::Services::Client).to receive(:object).with(druid).and_return(client)
      end

      context 'when version is not passed (deprecated)' do
        it 'draws milestones from the current version and notifies honeybadger' do
          expect(Honeybadger).to receive(:notify)

          get "/dor/objects/#{druid}/lifecycle?active-only=true"
          expect(returned_milestone_versions).to eq ['2']
          expect(returned_milestone_text).to eq ['submitted']
        end
      end

      context 'when version is passed' do
        it 'draws milestones from the current version' do
          get "/dor/objects/#{druid}/lifecycle?active-only=true&version=2"
          expect(returned_milestone_versions).to eq ['2']
          expect(returned_milestone_text).to eq ['submitted']
        end
      end
    end
  end

  context 'when active-only is not set' do
    let(:wf) do
      FactoryBot.create(:workflow_step,
                        process: 'start-accession',
                        version: 1,
                        lane_id: 'default',
                        status: 'completed',
                        lifecycle: 'submitted')
    end

    before do
      FactoryBot.create(:workflow_step,
                        druid: druid,
                        version: 2,
                        process: 'start-accession',
                        status: 'completed',
                        lifecycle: 'submitted')

      # This is not a lifecycle event, so it shouldn't display.
      FactoryBot.create(:workflow_step,
                        druid: druid,
                        version: 2,
                        process: 'rights-metadata',
                        lane_id: 'fast',
                        status: 'completed')

      # This is not a complete event, so it shouldn't display.
      FactoryBot.create(:workflow_step,
                        druid: druid,
                        version: 2,
                        process: 'sdr-ingest-transfer',
                        status: 'waiting',
                        lifecycle: 'indexed')
    end

    it 'draws milestones from the all versions' do
      get "/dor/objects/#{druid}/lifecycle"
      expect(returned_milestone_versions).to match_array %w[1 2]
      expect(returned_milestone_text).to match_array %w[submitted submitted]
    end
  end
end
