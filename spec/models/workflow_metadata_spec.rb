# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkflowMetadata do
  let(:workflow_metadata) { FactoryBot.create(:workflow_metadata) }

  it 'includes the metadata as a hash' do
    expect(workflow_metadata.values).to eq({ 'requireOCR' => true, 'requireTranscript' => true })
  end

  it 'validates that only one workflow metadata per druid and version is allowed' do
    expect(workflow_metadata).to be_valid # original is valid

    # new with same version is invalid
    expect do
      FactoryBot.create(:workflow_metadata, druid: workflow_metadata.druid,
                                            version: workflow_metadata.version)
    end.to raise_error(ActiveRecord::RecordInvalid)

    # new with different version is valid
    expect(FactoryBot.create(:workflow_metadata, druid: workflow_metadata.druid,
                                                 version: workflow_metadata.version + 1)).to be_valid
  end
end
