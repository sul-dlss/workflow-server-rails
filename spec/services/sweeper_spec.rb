# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sweeper do
  let(:wf_creator) do
    described_class.new(
      workflow_id: wf_parser.workflow_id,
      processes: wf_parser.processes,
      version: Version.new(druid: druid,
                           repository: repository,
                           version: 1)
    )
  end

  before do
    allow(QueueService).to receive(:enqueue)
  end

  describe '.sweep' do
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
                        process: 'rights-metadata',
                        version: 2,
                        status: 'waiting',
                        active_version: true)
    end

    it 'requeues the old steps' do
      described_class.sweep
      expect(QueueService).to have_received(:enqueue).exactly(2).times
      expect(QueueService).to have_received(:enqueue).with(stale)
      expect(QueueService).to have_received(:enqueue).with(less_stale)
    end
  end
end
