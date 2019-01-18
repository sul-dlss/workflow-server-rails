# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Close a version', type: :request do
  let(:druid) { FactoryBot.build(:workflow_step).druid }
  let(:xml) do
    <<~XML
      <workflow id="versioningWF">
        <process name="start-version" status="completed" attempts="1" lifecycle="opened"/>
        <process name="submit-version" status="waiting"/>
        <process name="start-accession" status="waiting"/>
      </workflow>
    XML
  end

  before do
    wf_client = instance_double(Dor::Services::Client::Workflows, initial: xml)
    obj_client = instance_double(Dor::Services::Client::Object, current_version: '2')

    allow(Dor::Services::Client).to receive(:workflows).and_return(wf_client)
    allow(Dor::Services::Client).to receive(:object).with(druid).and_return(obj_client)
  end

  it 'closes the version' do
    post "/dor/objects/#{druid}/versionClose"
    expect(response).to be_successful
    expect(WorkflowStep.where(druid: druid).count).to eq 3
  end
end
