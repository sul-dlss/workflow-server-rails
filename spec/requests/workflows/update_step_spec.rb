# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Update a workflow step for an object', type: :request do
  let(:client) { instance_double(Dor::Services::Client::Object, current_version: '1') }
  let(:druid) { wf.druid }

  before do
    allow(Dor::Services::Client).to receive(:object).with(druid).and_return(client)
  end

  let(:process_xml) do
    '<process name="start-accession" status="completed" elapsed="3" laneId="default" note="Yay"/>'
  end

  before do
    allow(SendUpdateMessage).to receive(:publish)
  end

  context 'with XML indicating success' do
    let(:wf) do
      FactoryBot.create(:workflow_step,
                        status: 'error',
                        error_msg: 'Bang!',
                        lifecycle: 'submitted')
    end

    it 'clears the old error message, but preserves the lifecycle' do
      put "/dor/objects/#{druid}/workflows/#{wf.workflow}/#{wf.process}", params: process_xml

      wf.reload
      expect(wf.status).to eq 'completed'
      expect(wf.error_msg).to be_nil

      expect(wf.lifecycle).to eq 'submitted'

      expect(response.body).to eq '{"next_steps":[]}'
      expect(SendUpdateMessage).to have_received(:publish).with(druid: wf.druid)
    end
  end

  context 'when no matching step exists (Hydrus does this)' do
    let(:druid) { 'druid:zz696qh8598' }
    let(:wf) { WorkflowStep.where(druid: druid, workflow: 'hydrusAssemblyWF', process: 'submit') }
    let(:process_xml) { '<process name="submit" status="completed" elapsed="3" lifecycle="submitted" laneId="default" note="Yay"/>' }

    it 'creates the step' do
      put "/dor/objects/#{druid}/workflows/hydrusAssemblyWF/submit", params: process_xml
      expect(wf.pluck(:status)).to eq ['completed']
      expect(response.body).to eq '{"next_steps":[]}'
      expect(SendUpdateMessage).to have_received(:publish).with(druid: druid)
    end
  end

  context 'with error XML' do
    let(:wf) { FactoryBot.create(:workflow_step) }

    let(:process_xml) do
      '<process name="start-accession" status="error" errorMessage="failed to do the thing" errorText="box1.foo.edu"/>'
    end

    it 'updates the step with error message/text' do
      put "/dor/objects/#{druid}/workflows/#{wf.workflow}/#{wf.process}", params: process_xml

      expect(wf.reload.status).to eq 'error'
      expect(response.body).to eq '{"next_steps":[]}'
      expect(SendUpdateMessage).to have_received(:publish).with(druid: wf.druid)
    end
  end

  context 'when process names do not match' do
    let(:wf) { FactoryBot.create(:workflow_step) }

    let(:process_xml) do
      '<process name="other-metadata" status="completed"/>'
    end

    it 'returns a 400 and does not update the step' do
      expect_any_instance_of(WorkflowStep).not_to receive(:update)

      put "/dor/objects/#{druid}/workflows/#{wf.workflow}/#{wf.process}", params: process_xml

      expect(response).to be_bad_request
      expect(SendUpdateMessage).not_to have_received(:publish)
    end
  end

  context 'when current-status is set' do
    let(:wf) { FactoryBot.create(:workflow_step) }

    context 'and it does not match the current status' do
      it 'does not update the step' do
        expect_any_instance_of(WorkflowStep).not_to receive(:update)

        put "/dor/objects/#{druid}/workflows/#{wf.workflow}/#{wf.process}?current-status=waiting", params: process_xml

        # NOTE: `#be_conflict` does not exist as a matcher for 409 errors
        expect(response.status).to eq 409
        expect(SendUpdateMessage).not_to have_received(:publish)
      end
    end

    context 'and it matches the current status' do
      let(:wf) { FactoryBot.create(:workflow_step, status: 'hold') }

      it 'updates the step' do
        put "/dor/objects/#{druid}/workflows/#{wf.workflow}/#{wf.process}?current-status=hold", params: process_xml

        expect(wf.reload.status).to eq 'completed'
        expect(response.body).to eq '{"next_steps":[]}'
        expect(SendUpdateMessage).to have_received(:publish).with(druid: wf.druid)
      end
    end
  end
end
