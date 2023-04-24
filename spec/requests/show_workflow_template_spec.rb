# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show a workflow template' do
  context 'when template exists' do
    it 'draws an empty set of milestones' do
      get '/workflow_templates/assemblyWF'
      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json['processes']).to eq [
        { 'label' => 'Initiate assembly of the object',
          'name' => 'start-assembly' },
        { 'label' =>
          'Create contentMetadata.xml from stub (from Goobi) if it exists; any contentMetadata.xml is converted and posted to cocina object',
          'name' => 'content-metadata-create' },
        { 'label' => 'Create JP2 derivatives for images in object',
          'name' => 'jp2-create' },
        { 'label' => 'Compute and compare checksums for any files referenced in cocina',
          'name' => 'checksum-compute' },
        { 'label' => 'Calculate and add exif, mimetype, file size and other attributes to each file in cocina',
          'name' => 'exif-collect' },
        { 'label' => 'Initiate workspace and start common accessioning',
          'name' => 'accessioning-initiate' }
      ]
    end
  end

  context 'when template does not exist' do
    it 'returns 404' do
      get '/workflow_templates/foo'

      expect(response).to have_http_status(:not_found)
    end
  end
end
