# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Close a version', type: :request do
  let(:druid) { FactoryBot.build(:workflow_step).druid }

  before do
    allow(QueueService).to receive(:enqueue)
  end

  context 'when version is not passed (deprecated)' do
    let(:object_client) { instance_double(Dor::Services::Client::Object, version: version_client) }
    let(:version_client) { instance_double(Dor::Services::Client::ObjectVersion, current: '2') }

    before do
      allow(Dor::Services::Client).to receive(:object).with(druid).and_return(object_client)
    end

    context 'with repository route (deprecated)' do
      it 'closes the version and notifies honeybadger' do
        expect(Honeybadger).to receive(:notify)

        post "/dor/objects/#{druid}/versionClose"
        expect(response).to be_successful
        expect(WorkflowStep.where(druid: druid).count).to eq 16
      end
    end

    it 'closes the version' do
      post "/objects/#{druid}/versionClose"
      expect(response).to be_successful
      expect(WorkflowStep.where(druid: druid).count).to eq 16
    end
  end

  context 'when version is passed' do
    it 'closes the version' do
      post "/objects/#{druid}/versionClose?version=3"
      expect(response).to be_successful
      expect(WorkflowStep.where(druid: druid).count).to eq 16
    end
  end
end
