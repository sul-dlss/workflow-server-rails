# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Lifecycle', type: :request do
  let(:wf) do
    # This should not appear in the results
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

  it 'draws milestones from the current version' do
    get "/dor/objects/#{druid}/lifecycle"
    expect(response).to render_template(:lifecycle)
    xml = Nokogiri::XML(response.body)
    expect(xml.at_xpath('//lifecycle/milestone').attr('version')).to eq '2'
    expect(xml.xpath('//lifecycle/milestone').length).to eq 1
  end
end
