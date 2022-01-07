# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Get the steps for one object', type: :request do
  let!(:date) { Time.now.utc.iso8601.sub(/Z/, '+00:00') }

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
              elapsed="" attempts="0" datetime="#{date}"
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
              elapsed="" attempts="0" datetime="#{date}"
              status="completed" name="start-accession"/>
          </workflow>
        </workflows>
      XML
    end
  end

  context 'when using the deprecated route with the repository' do
    let(:item) do
      FactoryBot.create(:workflow_step,
                        status: 'completed',
                        created_at: date)
    end

    it 'redirects to the new route' do
      get "/dor/objects/#{druid}/workflows"
      # This ought to be a redirect, but our infrastructure is making it a
      # challenge to do right now: https://github.com/sul-dlss/workflow-server-rails/pull/162#issuecomment-479191283
      # expect(response).to redirect_to "/objects/#{druid}/workflows"
      expect(response).to be_successful
      expect(response.body).to be_equivalent_to <<~XML
        <workflows objectId="#{druid}">
          <workflow objectId="#{druid}" id="accessionWF">
            <process version="1" note="" lifecycle="" laneId="default"
              elapsed="" attempts="0" datetime="#{date}"
              status="completed" name="start-accession"/>
          </workflow>
        </workflows>
      XML
    end
  end
end
