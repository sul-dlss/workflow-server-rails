# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'All queued steps' do
  before do
    # This is waiting, so it shouldn't appear in the results
    FactoryBot.create(:workflow_step,
                      process: 'shelve',
                      status: 'waiting')

    # This is newer than the threshold, so it shouldn't appear in results
    FactoryBot.create(:workflow_step,
                      process: 'shelve',
                      lane_id: 'fast',
                      status: 'queued')
  end

  let(:expected_xml) do
    <<~XML
      <workflows>
        <workflow name="accessionWF" process="shelve" druid="#{one.druid}" laneId="default"/>
        <workflow name="accessionWF" process="publish" druid="#{two.druid}" laneId="fast"/>
      </workflows>
    XML
  end

  let!(:one) do
    FactoryBot.create(:workflow_step,
                      process: 'shelve',
                      status: 'queued',
                      updated_at: 2.days.ago)
  end

  let!(:two) do
    FactoryBot.create(:workflow_step,
                      process: 'publish',
                      lane_id: 'fast',
                      status: 'queued',
                      updated_at: 3.days.ago)
  end

  context 'with repository query arg' do
    it 'shows all the queued items' do
      get '/workflow_queue/all_queued?repository=dor&limit=3&hours-ago=24'

      expect(response.body).to be_equivalent_to expected_xml
    end
  end

  context 'without repository query arg' do
    it 'shows all the queued items' do
      get '/workflow_queue/all_queued?limit=3&hours-ago=24'

      expect(response.body).to be_equivalent_to expected_xml
    end
  end
end
