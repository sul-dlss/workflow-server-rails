# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Lanes', type: :request do
  let!(:one) do
    FactoryBot.create(:workflow_step,
                      datastream: 'accessionWF',
                      process: 'shelve',
                      lane_id: 'default',
                      status: 'waiting')
  end
  let!(:two) do
    FactoryBot.create(:workflow_step,
                      datastream: 'accessionWF',
                      process: 'shelve',
                      lane_id: 'default',
                      status: 'queued',
                      updated_at: 2.days.ago)
  end

  let!(:three) do
    FactoryBot.create(:workflow_step,
                      datastream: 'accessionWF',
                      process: 'shelve',
                      lane_id: 'fast',
                      status: 'queued')
  end

  let!(:four) do
    FactoryBot.create(:workflow_step,
                      datastream: 'accessionWF',
                      process: 'accept',
                      lane_id: 'fast',
                      status: 'queued',
                      updated_at: 3.days.ago)
  end

  it 'shows all the queued items' do
    get '/workflow_queue/all_queued?repository=dor&limit=3&hours-ago=24'
    expect(response).to render_template(:all_queued)

    expect(response.body).to be_equivalent_to <<~XML
      <workflows>
        <workflow name="accessionWF" process="shelve" druid="#{two.druid}" laneId="default"/>
        <workflow name="accessionWF" process="accept" druid="#{four.druid}" laneId="fast"/>
      </workflows>
    XML
  end
end
