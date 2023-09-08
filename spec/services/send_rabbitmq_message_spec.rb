# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SendRabbitmqMessage do
  describe '.publish' do
    let(:service) { described_class.new(step:, channel:) }
    let(:step) { FactoryBot.create(:workflow_step, druid:) }

    let(:druid) { 'druid:bb123bc1234' }
    let(:channel) { instance_double(Bunny::Channel) }
    let(:exchange) { instance_double(Bunny::Exchange) }

    before do
      allow(channel).to receive(:topic).and_return(exchange)
      allow(exchange).to receive(:publish)
    end

    it 'sends message' do
      service.publish
      expect(exchange).to have_received(:publish).with(
        {
          version: 1,
          note: nil,
          lifecycle: nil,
          laneId: 'default',
          elapsed: nil,
          attempts: 0,
          datetime: step.updated_at.to_time.iso8601,
          status: 'waiting',
          name: 'start-accession',
          action: 'workflow updated',
          druid:
        }.to_json,
        routing_key: 'start-accession.waiting'
      )
      expect(channel).to have_received(:topic).with('sdr.workflow')
    end
  end
end
