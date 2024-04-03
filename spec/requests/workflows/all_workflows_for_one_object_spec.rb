# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Get the steps for one object' do
  let!(:date) { Time.now.utc.iso8601.sub('Z', '+00:00') }

  let(:druid) { item.druid }

  context 'when error' do
    let(:item) do
      FactoryBot.create(:workflow_step,
                        status: 'error',
                        error_msg: 'it just broke',
                        created_at: date)
    end

    it 'shows the error message' do
      get "/objects/#{druid}/workflows"
      expect(response).to be_successful
      expect(response.body).to be_equivalent_to <<~XML
        <workflows objectId="#{druid}">
          <workflow objectId="#{druid}" id="accessionWF">
            <process version="1" note="" lifecycle="" laneId="default"
              elapsed="" attempts="0" datetime="#{date}" metadata=""
              status="error" name="start-accession" errorMessage="it just broke"/>
          </workflow>
        </workflows>
      XML
    end
  end

  context 'when a successful step' do
    let(:item) do
      FactoryBot.create(:workflow_step,
                        status: 'completed',
                        created_at: date)
    end

    it 'does not have an error message' do
      get "/objects/#{druid}/workflows"
      expect(response).to be_successful
      expect(response.body).to be_equivalent_to <<~XML
        <workflows objectId="#{druid}">
          <workflow objectId="#{druid}" id="accessionWF">
            <process version="1" note="" lifecycle="" laneId="default"
              elapsed="" attempts="0" datetime="#{date}" metadata=""
              status="completed" name="start-accession"/>
          </workflow>
        </workflows>
      XML
    end
  end

  context 'when a successful step with metadata' do
    let(:item_metadata) { FactoryBot.create(:workflow_metadata, created_at: date) }
    let(:druid) { item_metadata.druid }

    it 'does not have an error message and shows the metadata' do
      get "/objects/#{druid}/workflows"
      expect(response).to be_successful
      expect(response.body).to be_equivalent_to <<~XML
        <workflows objectId="#{druid}">
          <workflow objectId="#{druid}" id="accessionWF">
            <process version="1" note="" lifecycle="" laneId="default"
              elapsed="" attempts="0" datetime="#{date}"
              metadata="{&quot;requireOCR&quot;=&gt;true, &quot;requireTranscript&quot;=&gt;true}"
              status="waiting" name="start-accession"/>
          </workflow>
        </workflows>
      XML
    end
  end
end
