# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'List the workflow templates' do
  it 'draws name and label' do
    get '/workflow_templates'
    expect(response).to have_http_status(:ok)
    json = response.parsed_body
    expect(json).to eq %w[
      accession2WF
      accessionWF
      assemblyWF
      digitizationWF
      disseminationWF
      dpgImageWF
      eemsAccessionWF
      etdSubmitWF
      gisAssemblyWF
      gisDeliveryWF
      gisDiscoveryWF
      goobiWF
      googleScannedBookWF
      hydrusAssemblyWF
      preservationAuditWF
      preservationIngestWF
      registrationWF
      releaseWF
      sdrAuditWF
      sdrIngestWF
      sdrMigrationWF
      sdrRecoveryWF
      swIndexWF
      versioningWF
      wasCrawlDisseminationWF
      wasCrawlPreassemblyWF
      wasDisseminationWF
      wasSeedDisseminationWF
      wasSeedPreassemblyWF
    ]
  end
end
