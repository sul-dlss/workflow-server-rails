# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Get the steps for one object', type: :request do
  let(:date) { Time.now.utc.iso8601.sub(/Z/, '+00:00') }

  let(:error_step) do
    FactoryBot.create(:workflow_step,
                      status: 'error',
                      error_msg: 'it just broke',
                      created_at: date)
  end

  let(:druid) { error_step.druid }

  it 'shows the steps' do
    get "/dor/objects/#{druid}/workflows"
    expect(response).to be_successful
    expect(response.body).to be_equivalent_to <<~XML
      <workflows objectId="#{druid}">
        <workflow repository="dor" objectId="#{druid}" id="accessionWF">
          <process version="1" priority="0" note="" lifecycle="" laneId="default"
            elapsed="" attempts="0" datetime="#{date}"
            status="error" name="start-accession" errorMessage="it just broke"/>
        </workflow>
      </workflows>
    XML
  end
end
