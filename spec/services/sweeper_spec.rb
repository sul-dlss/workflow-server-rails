# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sweeper do
  before do
    allow(QueueService).to receive(:enqueue)
    allow(Honeybadger).to receive(:notify)
  end

  describe '.sweep' do
    let(:stale) do
      FactoryBot.create(:workflow_step,
                        process: 'start-accession',
                        version: 2,
                        status: 'queued',
                        active_version: true,
                        updated_at: 2.days.ago)
    end
    let!(:stale_version) do
      FactoryBot.create(:workflow_step,
                        druid: stale.druid,
                        process: 'start-accession',
                        version: 1,
                        status: 'queued',
                        active_version: false,
                        updated_at: 2.days.ago)
    end
    let!(:on_deck) do
      FactoryBot.create(:workflow_step,
                        druid: stale.druid,
                        process: 'descriptive-metadata',
                        version: 2,
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
    let!(:less_stale) do
      FactoryBot.create(:workflow_step,
                        druid: completed.druid,
                        process: 'descriptive-metadata',
                        version: 2,
                        status: 'queued',
                        active_version: true,
                        updated_at: 15.hours.ago)
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

    it 'requeues stale steps and notifies Honeybadger' do
      described_class.sweep
      expect(QueueService).to have_received(:enqueue).exactly(3).times
      expect(QueueService).to have_received(:enqueue).with(stale)
      expect(QueueService).to have_received(:enqueue).with(less_stale)
      expect(QueueService).to have_received(:enqueue).with(stale_started)
      expect(Honeybadger).to have_received(:notify).exactly(3).times
    end
  end
end
