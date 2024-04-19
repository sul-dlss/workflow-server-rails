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

    context 'when the version is passed without context' do
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

    context 'when the version is passed with context' do
      let(:context) { { 'requireOCR' => true, 'requireTranscript' => true } }
      let(:version) { 1 }

      it 'creates new workflows with context' do
        expect do
          post "/objects/#{druid}/workflows/#{workflow}?version=#{version}", params: { context: }
        end.to change(WorkflowStep, :count).by(10)
        expect(WorkflowStep.last.lane_id).to eq('default')
        expect(VersionContext.find_by(druid:, version:).values).to eq({ 'requireOCR' => 'true', 'requireTranscript' => 'true' })
        expect(SendUpdateMessage).to have_received(:publish).with(step: WorkflowStep)
      end
    end

    context 'when the version is passed with non hash context' do
      let(:string_context) { 'not JSON' }
      let(:version) { 1 }

      it 'returns the value as a string' do
        expect do
          post "/objects/#{druid}/workflows/#{workflow}?version=#{version}", params: { context: string_context }
        end.to change(WorkflowStep, :count).by(10)
        expect(VersionContext.where(druid:, version:).count).to eq(1) # we have one context record
        expect(VersionContext.find_by(druid:, version:).values).to eq(string_context)
      end
    end

    context 'when the version is passed with updated context' do
      let(:original_context) { { 'requireOCR' => true, 'requireTranscript' => true } }
      let(:new_context) { { 'requireOCR' => false, 'requireTranscript' => true } }
      let(:version) { 1 }

      it 'updates existing workflow context' do
        # first create the workflow with original context
        expect do
          post "/objects/#{druid}/workflows/#{workflow}?version=#{version}", params: { context: original_context }
        end.to change(WorkflowStep, :count).by(10)
        expect(VersionContext.where(druid:, version:).count).to eq(1) # we have one context record
        expect(VersionContext.find_by(druid:, version:).values).to eq({ 'requireOCR' => 'true', 'requireTranscript' => 'true' })

        # next create the workflow with new context
        expect do
          post "/objects/#{druid}/workflows/#{workflow}?version=#{version}", params: { context: new_context }
        end.not_to change(WorkflowStep, :count) # no new workflow steps created, they just got replaced
        expect(VersionContext.where(druid:, version:).count).to eq(1) # we still have one context record
        # has new context
        expect(VersionContext.find_by(druid:, version:).values).to eq({ 'requireOCR' => 'false', 'requireTranscript' => 'true' })
      end
    end

    context 'when the version is passed with blank context' do
      let(:original_context) { { 'requireOCR' => true, 'requireTranscript' => true } }
      let(:blank_context) { '' }
      let(:version) { 1 }

      it 'removes the existing workflow context' do
        # first create the workflow with original context
        expect do
          post "/objects/#{druid}/workflows/#{workflow}?version=#{version}", params: { context: original_context }
        end.to change(WorkflowStep, :count).by(10)
        expect(VersionContext.where(druid:, version:).count).to eq(1) # we have one context record
        expect(VersionContext.find_by(druid:, version:).values).to eq({ 'requireOCR' => 'true', 'requireTranscript' => 'true' })

        # next create the workflow passing in blank context
        expect do
          post "/objects/#{druid}/workflows/#{workflow}?version=#{version}", params: { context: blank_context }
        end.not_to change(WorkflowStep, :count) # no new workflow steps created, they just got replaced
        expect(VersionContext.where(druid:, version:).count).to eq(0) # all gone
      end
    end

    context 'when the version is passed with no new context' do
      let(:original_context) { { 'requireOCR' => true, 'requireTranscript' => true } }
      let(:version) { 1 }

      it 'leaves the existing workflow context alone' do
        # first create the workflow with original context
        expect do
          post "/objects/#{druid}/workflows/#{workflow}?version=#{version}", params: { context: original_context }
        end.to change(WorkflowStep, :count).by(10)
        expect(VersionContext.where(druid:, version:).count).to eq(1) # we have one context record
        expect(VersionContext.find_by(druid:, version:).values).to eq({ 'requireOCR' => 'true', 'requireTranscript' => 'true' })

        # next create the workflow without passing in any context
        expect do
          post "/objects/#{druid}/workflows/#{workflow}?version=#{version}"
        end.not_to change(WorkflowStep, :count) # no new workflow steps created, they just got replaced
        expect(VersionContext.where(druid:, version:).count).to eq(1) # we still have one context record
        # original context
        expect(VersionContext.find_by(druid:, version:).values).to eq({ 'requireOCR' => 'true', 'requireTranscript' => 'true' })
      end

      context 'when the version is passed with nil context' do
        let(:original_context) { { 'requireOCR' => true, 'requireTranscript' => true } }
        let(:version) { 1 }

        it 'leaves the existing workflow context alone' do
          # first create the workflow with original context
          expect do
            post "/objects/#{druid}/workflows/#{workflow}?version=#{version}", params: { context: original_context }
          end.to change(WorkflowStep, :count).by(10)
          expect(VersionContext.where(druid:, version:).count).to eq(1) # we have one context record
          expect(VersionContext.find_by(druid:, version:).values).to eq({ 'requireOCR' => 'true', 'requireTranscript' => 'true' })

          # next create the workflow passing in nil context
          expect do
            post "/objects/#{druid}/workflows/#{workflow}?version=#{version}", params: { context: nil }
          end.not_to change(WorkflowStep, :count) # no new workflow steps created, they just got replaced
          expect(VersionContext.where(druid:, version:).count).to eq(1) # we still have one context record
          # original context
          expect(VersionContext.find_by(druid:, version:).values).to eq({ 'requireOCR' => 'true', 'requireTranscript' => 'true' })
        end
      end
    end
  end
end
