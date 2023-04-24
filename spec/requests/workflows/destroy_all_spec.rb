# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Get a single workflow for an object' do
  context 'when workflows exists for the object' do
    # rubocop:disable RSpec/IndexedLet
    let!(:item1) { FactoryBot.create(:workflow_step) }
    let!(:item2) { FactoryBot.create(:workflow_step, process: 'publish', druid: druid) }
    let!(:item3) { FactoryBot.create(:workflow_step, process: 'shelve') }
    # rubocop:enable RSpec/IndexedLet

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
