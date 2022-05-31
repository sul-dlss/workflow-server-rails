# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Destroy a workflow' do
  let(:wf) { FactoryBot.create(:workflow_step) }
  let(:druid) { wf.druid }

  context 'with repo (deprecated)' do
    it 'deletes workflows' do
      delete "/dor/objects/#{druid}/workflows/#{wf.workflow}?version=1"
      expect(response).to be_no_content
    end
  end

  context 'without repo' do
    it 'deletes workflows' do
      delete "/objects/#{druid}/workflows/#{wf.workflow}?version=1"
      expect(response).to be_no_content
    end
  end
end
