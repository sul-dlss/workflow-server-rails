# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Get a single workflow for an object' do
  context 'when a workflow exists for the object' do
    let(:item) do
      FactoryBot.create(:workflow_step,
                        status: 'waiting',
                        created_at: date)
    end

    let(:date) { Time.now.utc.iso8601.sub('Z', '+00:00') }
    let(:druid) { item.druid }

    it 'shows the workflow' do
      get "/objects/#{druid}/workflows/accessionWF"
      expect(response).to be_successful
      expect(response.body).to be_equivalent_to <<~XML
        <workflow objectId="#{druid}" id="accessionWF">
          <process version="1" note="" lifecycle="" laneId="default"
            elapsed="" attempts="0" datetime="#{date}" metadata=""
            status="waiting" name="start-accession"/>
        </workflow>
      XML
    end
  end

  context 'when a workflow exists for the object with metadata' do
    let(:item_metadata) { FactoryBot.create(:workflow_metadata, created_at: date) }

    let(:date) { Time.now.utc.iso8601.sub('Z', '+00:00') }
    let(:druid) { item_metadata.druid }

    it 'shows the workflow with metadata' do
      get "/objects/#{druid}/workflows/accessionWF"
      expect(response).to be_successful
      expect(response.body).to be_equivalent_to <<~XML
        <workflow objectId="#{druid}" id="accessionWF">
          <process version="1" note="" lifecycle="" laneId="default" elapsed=""
           attempts="0" datetime="#{date}"
           metadata="{&quot;requireOCR&quot;=&gt;true, &quot;requireTranscript&quot;=&gt;true}"
          status="waiting" name="start-accession"/>
        </workflow>
      XML
    end
  end

  context 'when no workflow exists' do
    let(:druid) { 'druid:bb123bb12342' }

    it 'returns an empy workflow node' do
      get "/objects/#{druid}/workflows/accessionWF"
      expect(response).to be_successful
      expect(response.body).to be_equivalent_to <<~XML
        <workflow objectId="#{druid}" id="accessionWF" />
      XML
    end
  end
end
