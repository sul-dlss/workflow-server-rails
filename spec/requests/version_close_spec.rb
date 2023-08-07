# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Close a version' do
  let(:druid) { FactoryBot.build(:workflow_step).druid }

  before do
    allow(QueueService).to receive(:enqueue)
    allow(SendUpdateMessage).to receive(:publish)
  end

  it 'closes the version' do
    post "/objects/#{druid}/versionClose?version=3"
    expect(response).to be_successful
    expect(WorkflowStep.where(druid:).count).to eq 12
  end
end
