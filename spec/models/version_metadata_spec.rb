# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VersionMetadata do
  let(:version_metadata) { FactoryBot.create(:version_metadata) }

  it 'includes the metadata as a hash' do
    expect(version_metadata.values).to eq({ 'requireOCR' => true, 'requireTranscript' => true })
  end

  it 'validates the uniqueness of druid and version combination' do
    expect(described_class.new(druid: version_metadata.druid, version: version_metadata.version)).not_to be_valid
  end

  it 'validates the druid' do
    expect(described_class.new(druid: 'foo', version: '1')).not_to be_valid
  end
end
