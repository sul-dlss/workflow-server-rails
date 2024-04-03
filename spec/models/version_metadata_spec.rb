# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VersionMetadata do
  let(:version_metadata) { FactoryBot.create(:version_metadata) }
  let(:druid) { version_metadata.druid }
  let(:version) { version_metadata.version }

  it 'includes the metadata as a hash' do
    expect(version_metadata.values).to eq({ 'requireOCR' => true, 'requireTranscript' => true })
  end
end
