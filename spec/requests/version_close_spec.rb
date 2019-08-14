# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Close a version', type: :request do
  let(:druid) { FactoryBot.build(:workflow_step).druid }
  let(:object_client) { instance_double(Dor::Services::Client::Object, version: version_client) }
  let(:version_client) { instance_double(Dor::Services::Client::ObjectVersion, current: '2') }

  before do
    allow(Dor::Services::Client).to receive(:object).with(druid).and_return(object_client)
    allow(QueueService).to receive(:enqueue)
  end

  it 'closes the version' do
    post "/dor/objects/#{druid}/versionClose"
    expect(response).to be_successful
    expect(WorkflowStep.where(druid: druid).count).to eq 13
  end
end
