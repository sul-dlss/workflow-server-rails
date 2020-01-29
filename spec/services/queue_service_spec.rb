# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QueueService do
  let(:service) { described_class.new step }

  let(:step) { FactoryBot.create(:workflow_step, workflow: 'assemblyWF', process: 'jp2-create') }

  describe '#enqueue' do
    before do
      allow(Resque).to receive(:enqueue_to).and_return(true)
    end

    context 'for JP2 robot (special case)' do
      let(:step) { FactoryBot.create(:workflow_step, workflow: 'assemblyWF', process: 'jp2-create') }

      it 'enqueues to Resque and updates status' do
        service.enqueue
        expect(Resque).to have_received(:enqueue_to).with('assemblyWF_jp2',
                                                          'Robots::DorRepo::Assembly::Jp2Create', step.druid)
        expect(step.status).to eq('queued')
      end
    end

    context 'for DorRepo classes' do
      let(:step) { FactoryBot.create(:workflow_step, workflow: 'accessionWF', process: 'descriptive-metadata') }

      it 'enqueues to Resque and updates status' do
        service.enqueue
        expect(Resque).to have_received(:enqueue_to).with('accessionWF_default',
                                                          'Robots::DorRepo::Accession::DescriptiveMetadata', step.druid)
        expect(step.status).to eq('queued')
      end
    end

    context 'for SdrRepo classes' do
      let(:step) { FactoryBot.create(:workflow_step, workflow: 'preservationIngestWF', process: 'transfer-object') }

      it 'enqueues to Resque and updates status' do
        service.enqueue
        expect(Resque).to have_received(:enqueue_to).with('preservationIngestWF_default',
                                                          'Robots::SdrRepo::PreservationIngest::TransferObject', step.druid)
        expect(step.status).to eq('queued')
      end
    end

    context 'when .enqueue_to returns false' do
      before do
        allow(Resque).to receive(:enqueue_to).and_return(false)
      end

      let(:step) { FactoryBot.create(:workflow_step, workflow: 'assemblyWF', process: 'jp2-create') }

      it 'raises' do
        expect { service.enqueue }.to raise_error(/Enqueueing/)
      end
    end
  end

  describe '#class_name' do
    let(:class_name) { service.send(:class_name) }

    it 'create correct class_name' do
      expect(class_name).to eq('Robots::DorRepo::Assembly::Jp2Create')
    end
  end
end
