# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkflowMonitor do
  before do
    allow(Honeybadger).to receive(:notify)
  end

  describe '.monitor' do
    let(:stale) do
      FactoryBot.create(:workflow_step,
                        process: 'start-accession',
                        version: 1,
                        status: 'queued',
                        active_version: true,
                        updated_at: 2.days.ago)
    end
    let!(:on_deck) do
      FactoryBot.create(:workflow_step,
                        druid: stale.druid,
                        process: 'descriptive-metadata',
                        version: 1,
                        status: 'waiting',
                        active_version: true)
    end

    let(:completed) do
      FactoryBot.create(:workflow_step,
                        process: 'start-accession',
                        version: 2,
                        status: 'completed',
                        active_version: true,
                        updated_at: 1.day.ago)
    end
    let!(:on_deck2) do
      FactoryBot.create(:workflow_step,
                        druid: completed.druid,
                        process: 'content-metadata',
                        version: 2,
                        status: 'waiting',
                        active_version: true)
    end
    let(:stale_started) do
      FactoryBot.create(:workflow_step,
                        process: 'start-accession',
                        version: 3,
                        status: 'started',
                        active_version: true,
                        updated_at: 2.days.ago)
    end
    let!(:started) do
      FactoryBot.create(:workflow_step,
                        druid: stale_started.druid,
                        process: 'descriptive-metadata',
                        version: 1,
                        status: 'waiting',
                        active_version: true)
    end

    it 'reports to Honeybadger' do
      described_class.monitor
      expect(Honeybadger).to have_received(:notify).exactly(2).times

      stale_started_msg = "Workflow step has been running for more than 24 hours: <druid:\"#{stale_started.druid}\" " \
                          "version:\"3\" workflow:\"#{stale_started.workflow}\" process:\"start-accession\">."
      expect(Honeybadger).to have_received(:notify).with(/#{stale_started_msg}/)

      stale_msg = '1 workflow steps have been queued for more than 12 hours. '
      expect(Honeybadger).to have_received(:notify).with(/#{stale_msg}/, context: { druids: [stale.druid] })
    end
  end
end
