# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Close a version', type: :request do
  let(:druid) { FactoryBot.build(:workflow_step).druid }

  before do
    obj_client = instance_double(Dor::Services::Client::Object, current_version: '2')

    allow(Dor::Services::Client).to receive(:object).with(druid).and_return(obj_client)
    allow(QueueService).to receive(:enqueue)
  end

  it 'closes the version' do
    post "/dor/objects/#{druid}/versionClose"
    expect(response).to be_successful
    expect(WorkflowStep.where(druid: druid).count).to eq 13
  end
end
