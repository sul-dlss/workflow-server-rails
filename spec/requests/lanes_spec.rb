# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Lanes' do
  before do
    FactoryBot.create(:workflow_step,
                      process: 'shelve',
                      lane_id: 'default',
                      status: 'waiting',
                      active_version: true)
    FactoryBot.create(:workflow_step,
                      process: 'shelve',
                      lane_id: 'fast',
                      status: 'waiting',
                      active_version: true)
    FactoryBot.create(:workflow_step,
                      process: 'shelve',
                      lane_id: 'fast',
                      status: 'completed',
                      active_version: true)
    FactoryBot.create(:workflow_step,
                      process: 'publish',
                      lane_id: 'fast',
                      status: 'waiting',
                      active_version: true)
  end

  let(:expected_xml) do
    '<lanes><lane id="default"/><lane id="fast"/></lanes>'
  end

  context 'with repository-qualified step names' do
    it 'shows the lanes' do
      get '/workflow_queue/lane_ids?step=dor:accessionWF:shelve'

      expect(response.body).to be_equivalent_to expected_xml
    end
  end

  context 'without repository-qualified step names' do
    it 'shows the lanes' do
      get '/workflow_queue/lane_ids?step=accessionWF:shelve'

      expect(response.body).to be_equivalent_to expected_xml
    end
  end
end
