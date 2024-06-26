# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SendRabbitmqMessage do
  describe '.publish' do
    let(:service) { described_class.new(step:, channel:) }

    let(:druid) { 'druid:bb123bc1234' }
    let(:version) { 1 }
    let(:channel) { instance_double(Bunny::Channel) }
    let(:exchange) { instance_double(Bunny::Exchange) }

    before do
      allow(channel).to receive(:topic).and_return(exchange)
      allow(exchange).to receive(:publish)
    end

    context 'without any context' do
      let(:step) { FactoryBot.create(:workflow_step, druid:) }

      it 'sends message' do
        service.publish
        expect(exchange).to have_received(:publish).with(
          {
            version:,
            note: nil,
            lifecycle: nil,
            laneId: 'default',
            elapsed: nil,
            attempts: 0,
            datetime: step.updated_at.to_time.iso8601,
            context: nil,
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

    context 'with context' do
      let(:step) { FactoryBot.create(:workflow_step, :with_ocr_context, druid:) }

      it 'sends message' do
        service.publish
        expect(exchange).to have_received(:publish).with(
          {
            version:,
            note: nil,
            lifecycle: nil,
            laneId: 'default',
            elapsed: nil,
            attempts: 0,
            datetime: step.updated_at.to_time.iso8601,
            context: VersionContext.find_by(druid:, version:).values.to_json,
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
end
