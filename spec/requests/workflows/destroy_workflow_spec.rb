# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Destroy a workflow' do
  let(:wf) { FactoryBot.create(:workflow_step) }
  let(:druid) { wf.druid }

  context 'when version is not passed (deprecated)' do
    let(:client) { instance_double(Dor::Services::Client::Object, version: version_client) }
    let(:version_client) { instance_double(Dor::Services::Client::ObjectVersion, current: '1') }

    before do
      allow(Dor::Services::Client).to receive(:object).with(druid).and_return(client)
    end

    it 'deletes workflows and notifies honeybadger' do
      expect(Honeybadger).to receive(:notify)

      delete "/dor/objects/#{druid}/workflows/#{wf.workflow}"
      expect(response).to be_no_content
    end
  end

  context 'when version is passed' do
    it 'deletes workflows' do
      delete "/dor/objects/#{druid}/workflows/#{wf.workflow}?version=1"
      expect(response).to be_no_content
    end
  end
end
