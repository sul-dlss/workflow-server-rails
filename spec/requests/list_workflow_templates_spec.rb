# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'List the workflow templates', type: :request do
  it 'draws name and label' do
    get '/workflow_templates'
    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)
    expect(json).to eq %w[
      accessionWF
      assemblyWF
      digitizationWF
      disseminationWF
      etdSubmitWF
      gisAssemblyWF
      gisDeliveryWF
      gisDiscoveryWF
      goobiWF
      hydrusAssemblyWF
      preservationAuditWF
      preservationIngestWF
      registrationWF
      releaseWF
      sdrIngestWF
      versioningWF
      wasCrawlDisseminationWF
      wasCrawlPreassemblyWF
      wasDisseminationWF
      wasSeedDisseminationWF
      wasSeedPreassemblyWF
    ]
  end
end
