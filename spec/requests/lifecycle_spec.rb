# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Lifecycle', type: :request do
  let(:wf) do
    # This should not appear in the results if they want active-only
    FactoryBot.create(:workflow_step,
                      process: 'opened',
                      version: 1,
                      lane_id: 'default',
                      status: 'waiting',
                      lifecycle: 'submitted')
  end

  let(:client) { double(current_version: '2') }
  let(:druid) { wf.druid }
  before do
    FactoryBot.create(:workflow_step,
                      druid: druid,
                      version: 2,
                      process: 'opened',
                      lane_id: 'fast',
                      status: 'waiting',
                      lifecycle: 'submitted')

    # This is not a lifecycle event, so it shouldn't display.
    FactoryBot.create(:workflow_step,
                      druid: druid,
                      version: 2,
                      process: 'start-accession',
                      lane_id: 'fast',
                      status: 'waiting')
    allow(Dor::Services::Client).to receive(:object).with(druid).and_return(client)
  end

  let(:xml) { Nokogiri::XML(response.body) }
  let(:returned_milestones) { xml.xpath('//lifecycle/milestone') }
  let(:returned_milestone_versions) { returned_milestones.map { |node| node.attr('version') } }
  let(:returned_milestone_text) { returned_milestones.map(&:text) }

  context 'when active-only is set' do
    it 'draws milestones from the current version' do
      get "/dor/objects/#{druid}/lifecycle?active-only=true"
      expect(response).to render_template(:lifecycle)
      expect(returned_milestone_versions).to eq ['2']
      expect(returned_milestone_text).to eq ['submitted']
    end
  end

  context 'when active-only is not set' do
    it 'draws milestones from the all versions' do
      get "/dor/objects/#{druid}/lifecycle"
      expect(response).to render_template(:lifecycle)
      expect(returned_milestone_versions).to include('1', '2')
      expect(returned_milestone_text).to include('submitted', 'submitted')
    end
  end
end
