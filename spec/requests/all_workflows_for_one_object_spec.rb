# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Get the steps for one object', type: :request do
  let(:date) { Time.now.utc.iso8601.sub(/Z/, '+00:00') }

  let(:druid) { item.druid }

  context 'for an error' do
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
          <workflow repository="dor" objectId="#{druid}" id="accessionWF">
            <process version="1" priority="0" note="" lifecycle="" laneId="default"
              elapsed="" attempts="0" datetime="#{date}"
              status="error" name="start-accession" errorMessage="it just broke"/>
          </workflow>
        </workflows>
      XML
    end
  end

  context 'for a successful step' do
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
          <workflow repository="dor" objectId="#{druid}" id="accessionWF">
            <process version="1" priority="0" note="" lifecycle="" laneId="default"
              elapsed="" attempts="0" datetime="#{date}"
              status="completed" name="start-accession"/>
          </workflow>
        </workflows>
      XML
    end
  end

  context 'the deprecated route with the repository' do
    let(:druid) { 'abc:123' }

    it 'redirects to the new route' do
      get "/dor/objects/#{druid}/workflows"
      expect(response).to redirect_to "/objects/#{druid}/workflows"
    end
  end
end
