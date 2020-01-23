# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Lanes', type: :request do
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
                      process: 'shelve-complete',
                      lane_id: 'fast',
                      status: 'waiting',
                      active_version: true)
  end

  it 'shows the lanes' do
    get '/workflow_queue/lane_ids?step=dor:accessionWF:shelve'

    expect(response.body).to be_equivalent_to '<lanes><lane id="default"/><lane id="fast"/></lanes>'
  end
end
