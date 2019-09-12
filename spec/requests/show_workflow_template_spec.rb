# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show a workflow template', type: :request do
  it 'draws an empty set of milestones' do
    get '/workflow_templates/assemblyWF'
    json = JSON.parse(response.body)
    expect(json['processes']).to eq [{ 'name' => 'start-assembly' },
                                     { 'name' => 'content-metadata-create' },
                                     { 'name' => 'jp2-create' },
                                     { 'name' => 'checksum-compute' },
                                     { 'name' => 'exif-collect' },
                                     { 'name' => 'accessioning-initiate' }]
  end
end
