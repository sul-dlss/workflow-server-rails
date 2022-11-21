# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Get a single workflow for an object' do
  context 'when workflows exists for the object' do
    let!(:item1) do
      FactoryBot.create(:workflow_step)
    end

    let!(:item2) do
      FactoryBot.create(:workflow_step,
                        process: 'publish',
                        druid: druid)
    end

    let!(:item3) do
      FactoryBot.create(:workflow_step, process: 'shelve')
    end

    let(:druid) { item1.druid }

    it 'shows the workflow' do
      expect do
        delete "/objects/#{druid}/workflows"
      end.to change(WorkflowStep, :count).by(-2)
      expect(response).to be_no_content
      # item3 doesn't get deleted
      expect(WorkflowStep.exists?(item3.id)).to be true
    end
  end
end
