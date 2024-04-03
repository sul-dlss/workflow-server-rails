# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a workflow' do
  let(:wf) { FactoryBot.create(:workflow_step) }
  let(:druid) { wf.druid }
  let(:workflow_template) { WorkflowTemplateLoader.load_as_xml('accessionWF') }

  before do
    allow(QueueService).to receive(:enqueue)
  end

  describe 'POST create' do
    let(:druid) { 'druid:bb123bb1234' }
    let(:workflow) { 'accessionWF' }
    let(:lane_id) { 'foo' }

    before do
      allow(SendUpdateMessage).to receive(:publish)
    end

    context 'when the version is passed without metadata' do
      it 'creates new workflows' do
        expect do
          post "/objects/#{druid}/workflows/#{workflow}?version=1"
        end.to change(WorkflowStep, :count).by(10)
        expect(WorkflowStep.last.lane_id).to eq('default')
        expect(SendUpdateMessage).to have_received(:publish).with(step: WorkflowStep)
      end

      it 'sets the lane id' do
        post "/objects/#{druid}/workflows/#{workflow}?lane-id=#{lane_id}&version=1"
        expect(WorkflowStep.last.lane_id).to eq(lane_id)
      end

      context 'with bad request' do
        let(:workflow) { 'xaccessionWF' }

        it 'returns a 400 error' do
          expect do
            post "/objects/#{druid}/workflows/#{workflow}?version=1"
          end.not_to change(WorkflowStep, :count)
          expect(response).to have_http_status :bad_request
        end
      end
    end

    context 'when the version is passed with metadata' do
      let(:metadata) { { 'requireOCR' => true, 'requireTranscript' => true } }
      let(:version) { 1 }

      it 'creates new workflows with metadata' do
        expect do
          post "/objects/#{druid}/workflows/#{workflow}?version=#{version}&metadata=#{ERB::Util.url_encode(metadata.to_json)}"
        end.to change(WorkflowStep, :count).by(10)
        expect(WorkflowStep.last.lane_id).to eq('default')
        expect(VersionMetadata.find_by(druid:, version:).values).to eq(metadata)
        expect(SendUpdateMessage).to have_received(:publish).with(step: WorkflowStep)
      end
    end

    context 'when the version is passed with updated metadata' do
      let(:original_metadata) { { 'requireOCR' => true, 'requireTranscript' => true } }
      let(:new_metadata) { { 'requireOCR' => true, 'requireTranscript' => true } }
      let(:version) { 1 }

      it 'updates existing workflow metadata' do
        # first create the workflow with original metadata
        expect do
          post "/objects/#{druid}/workflows/#{workflow}?version=#{version}&metadata=#{ERB::Util.url_encode(original_metadata.to_json)}"
        end.to change(WorkflowStep, :count).by(10)
        expect(VersionMetadata.where(druid:, version:).count).to eq(1) # we have one metadata record
        expect(VersionMetadata.find_by(druid:, version:).values).to eq(original_metadata)

        # next create the workflow with new metadata
        expect do
          post "/objects/#{druid}/workflows/#{workflow}?version=#{version}&metadata=#{ERB::Util.url_encode(new_metadata.to_json)}"
        end.not_to change(WorkflowStep, :count) # no new workflow steps created, they just got replaced
        expect(VersionMetadata.where(druid:, version:).count).to eq(1) # we still have one metadata record
        expect(VersionMetadata.find_by(druid:, version:).values).to eq(new_metadata) # but it has the new metadata
      end
    end

    context 'when the version is passed with blank metadata' do
      let(:original_metadata) { { 'requireOCR' => true, 'requireTranscript' => true } }
      let(:new_metadata) { {} }
      let(:version) { 1 }

      it 'removes the existing workflow metadata' do
        # first create the workflow with original metadata
        expect do
          post "/objects/#{druid}/workflows/#{workflow}?version=#{version}&metadata=#{ERB::Util.url_encode(original_metadata.to_json)}"
        end.to change(WorkflowStep, :count).by(10)
        expect(VersionMetadata.where(druid:, version:).count).to eq(1) # we have one metadata record
        expect(VersionMetadata.find_by(druid:, version:).values).to eq(original_metadata)

        # next create the workflow passing in blank metadata
        expect do
          post "/objects/#{druid}/workflows/#{workflow}?version=#{version}&metadata=#{ERB::Util.url_encode(new_metadata.to_json)}"
        end.not_to change(WorkflowStep, :count) # no new workflow steps created, they just got replaced
        expect(VersionMetadata.where(druid:, version:).count).to eq(0) # all gone
      end
    end

    context 'when the version is passed with no new metadata' do
      let(:original_metadata) { { 'requireOCR' => true, 'requireTranscript' => true } }
      let(:version) { 1 }

      it 'leaves the existing workflow metadata alone' do
        # first create the workflow with original metadata
        expect do
          post "/objects/#{druid}/workflows/#{workflow}?version=#{version}&metadata=#{ERB::Util.url_encode(original_metadata.to_json)}"
        end.to change(WorkflowStep, :count).by(10)
        expect(VersionMetadata.where(druid:, version:).count).to eq(1) # we have one metadata record
        expect(VersionMetadata.find_by(druid:, version:).values).to eq(original_metadata)

        # next create the workflow without passing in any metadata
        expect do
          post "/objects/#{druid}/workflows/#{workflow}?version=#{version}"
        end.not_to change(WorkflowStep, :count) # no new workflow steps created, they just got replaced
        expect(VersionMetadata.where(druid:, version:).count).to eq(1) # we still have one metadata record
        expect(VersionMetadata.find_by(druid:, version:).values).to eq(original_metadata) # and it still has the original metadata
      end
    end
  end
end
