# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkflowQueuesController do
  describe 'GET lane_ids' do
    before do
      FactoryBot.create(:workflow_step,
                        datastream: 'accessionWF',
                        process: 'shelve',
                        lane_id: 'default',
                        status: 'waiting')
      FactoryBot.create(:workflow_step,
                        datastream: 'accessionWF',
                        process: 'shelve',
                        lane_id: 'fast',
                        status: 'waiting')
      FactoryBot.create(:workflow_step,
                        datastream: 'accessionWF',
                        process: 'shelve',
                        lane_id: 'fast',
                        status: 'done')
      FactoryBot.create(:workflow_step,
                        datastream: 'accessionWF',
                        process: 'accept',
                        lane_id: 'fast',
                        status: 'waiting')
    end

    it 'loads ActiveRecord Relation and parses it to valid XML' do
      get :lane_ids, params: { step: 'dor:accessionWF:shelve', format: :xml }
      expect(response).to render_template 'lane_ids'
      expect(response).to be_successful
      expect(assigns[:lanes]).to eq %w[default fast]
    end
  end
end
