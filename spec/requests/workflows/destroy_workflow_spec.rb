# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Destroy a workflow' do
  let(:client) { instance_double(Dor::Services::Client::Object, version: version_client) }
  let(:version_client) { instance_double(Dor::Services::Client::ObjectVersion, current: '1') }
  let(:wf) { FactoryBot.create(:workflow_step) }
  let(:druid) { wf.druid }

  before do
    allow(Dor::Services::Client).to receive(:object).with(druid).and_return(client)
  end

  it 'deletes workflows' do
    delete "/dor/objects/#{druid}/workflows/#{wf.workflow}"
    expect(response).to be_no_content
  end
end
