# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show the archive' do
  let(:wf) { FactoryBot.create(:workflow_step) }

  it 'loads count of workflows' do
    get '/workflow_archive',
        params: { repository: 'dor', workflow: wf.workflow, format: :xml }
    expect(response.body).to be_equivalent_to '<objects count="1"/>'
  end
end
