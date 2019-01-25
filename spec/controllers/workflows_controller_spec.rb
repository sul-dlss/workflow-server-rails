# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkflowsController do
  include XmlFixtures
  let(:repository) { 'dor' }
  let(:client) { instance_double(Dor::Services::Client::Object, current_version: '1') }
  let(:wf) { FactoryBot.create(:workflow_step) }
  let(:druid) { wf.druid }

  before do
    allow(Dor::Services::Client).to receive(:object).with(druid).and_return(client)
  end

  describe 'GET index' do
    it 'loads and groups ActiveRecord Relation renders workflows' do
      get :index, params: { repo: wf.repository, druid: wf.druid, format: :xml }
      expect(assigns(:processes)).to be_an Hash
      expect(assigns(:processes).length).to eq 1
      expect(response).to render_template 'index'
    end
  end

  describe 'GET show' do
    it 'loads and groups ActiveRecord Relation renders workflows' do
      get :show, params: { repo: wf.repository, druid: wf.druid, workflow: wf.workflow, format: :xml }
      expect(assigns(:processes)).to be_an Hash
      expect(assigns(:processes).length).to eq 1
      expect(response).to render_template 'show'
    end
  end

  describe 'PUT update' do
    let(:process_xml) { update_process_to_completed }

    context 'with XML indicating success' do
      it 'updates the step' do
        put :update, body: process_xml,
                     params: { repo: wf.repository, druid: wf.druid, workflow: wf.workflow, process: wf.process }

        expect(wf.reload.status).to eq 'completed'
        expect(response).to be_no_content
      end
    end

    context 'with error XML' do
      let(:process_xml) { update_process_to_error }

      it 'updates the step with error message/text' do
        put :update, body: process_xml,
                     params: { repo: wf.repository, druid: wf.druid, workflow: wf.workflow, process: wf.process }

        expect(wf.reload.status).to eq 'error'
        expect(response).to be_no_content
      end
    end

    context 'when process names do not match' do
      let(:process_xml) { update_other_process }

      it 'returns a 400 and does not update the step' do
        expect_any_instance_of(WorkflowStep).not_to receive(:update)

        put :update, body: process_xml,
                     params: { repo: wf.repository, druid: wf.druid, workflow: wf.workflow, process: wf.process }

        expect(response).to be_bad_request
      end
    end

    context 'when current-status is set' do
      context 'and it does not match the current status' do
        it 'does not update the step' do
          expect_any_instance_of(WorkflowStep).not_to receive(:update)

          put :update, body: process_xml,
                       params: { repo: wf.repository, druid: wf.druid, workflow: wf.workflow, process: wf.process, 'current-status' => 'waiting' }

          # NOTE: `#be_conflict` does not exist as a matcher for 409 errors
          expect(response.status).to eq 409
        end
      end

      context 'and it matches the current status' do
        before do
          wf.update(status: 'hold')
        end

        it 'updates the step' do
          put :update, body: process_xml,
                       params: { repo: wf.repository, druid: wf.druid, workflow: wf.workflow, process: wf.process, 'current-status' => 'hold' }

          expect(wf.reload.status).to eq 'completed'
          expect(response).to be_no_content
        end
      end
    end
  end

  describe 'GET archive' do
    it 'loads count of workflows' do
      get :archive, params: { repository: wf.repository, workflow: wf.workflow, format: :xml }
      expect(assigns(:objects)).to eq 1
      expect(response).to render_template 'archive'
    end
  end

  describe 'DELETE destroy' do
    it 'deletes workflows' do
      delete :destroy, params: { repo: wf.repository, druid: wf.druid, workflow: wf.workflow, format: :xml }
      expect(response).to be_no_content
    end
  end

  describe 'PUT create' do
    let(:druid) { 'druid:abc123' }
    let(:workflow) { 'accessionWF' }
    let(:repository) { 'dor' }
    let(:request_data) { workflow_create }

    context 'when the version exists' do
      it 'creates new workflows' do
        expect do
          put :create, body: request_data, params: { repo: repository, druid: druid, workflow: workflow, format: :xml }
        end.to change(WorkflowStep, :count)
          .by(Nokogiri::XML(workflow_create).xpath('//process').count)
      end
    end

    context "when the version doesn't exist" do
      let(:client) { double }

      before do
        allow(client).to receive(:current_version).and_raise(Dor::Services::Client::NotFoundResponse)
      end

      it 'creates new workflows' do
        expect do
          put :create, body: request_data, params: { repo: repository, druid: druid, workflow: workflow, format: :xml }
        end.to change(WorkflowStep, :count)
          .by(Nokogiri::XML(workflow_create).xpath('//process').count)
      end
    end
  end
end
