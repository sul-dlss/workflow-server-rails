# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QueueService do
  let(:service) { described_class.new step }

  let(:step) { FactoryBot.create(:workflow_step, workflow: 'assemblyWF', process: 'jp2-create') }

  describe '#enqueue' do
    before do
      allow(Resque).to receive(:enqueue_to)
    end

    it 'enqueues to Resque and updates status' do
      service.enqueue
      expect(Resque).to have_received(:enqueue_to).with(:"dor_assemblyWF_jp2-create_default",
                                                        'Robots::DorRepo::Assembly::Jp2Create', step.druid)
      expect(step.status).to eq('queued')
    end
  end

  describe '#step_name' do
    let(:step_name) { service.send(:step_name) }

    it 'create correct step_name' do
      expect(step_name).to eq('dor:assemblyWF:jp2-create')
    end
  end

  describe '#queue_name' do
    let(:queue_name) { service.send(:queue_name) }

    it 'create correct queue_name' do
      expect(queue_name).to eq('dor_assemblyWF_jp2-create_default')
    end
  end

  describe '#class_name' do
    let(:class_name) { service.send(:class_name) }

    it 'create correct class_name' do
      expect(class_name).to eq('Robots::DorRepo::Assembly::Jp2Create')
    end
  end
end
