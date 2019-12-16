# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkflowsController do
  let(:repository) { 'dor' }
  let(:client) { instance_double(Dor::Services::Client::Object, version: version_client) }
  let(:version_client) { instance_double(Dor::Services::Client::ObjectVersion, current: '1') }
  let(:wf) { FactoryBot.create(:workflow_step) }
  let(:druid) { wf.druid }
  let(:workflow_template) { WorkflowTemplateLoader.load_as_xml('accessionWF', 'dor') }

  before do
    allow(Dor::Services::Client).to receive(:object).with(druid).and_return(client)
    allow(QueueService).to receive(:enqueue)
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

  describe 'deprecated PUT create' do
    let(:druid) { 'druid:bb123bb1234' }
    let(:workflow) { 'accessionWF' }
    let(:repository) { 'dor' }
    let(:request_data) { workflow_template }

    before do
      allow(SendUpdateMessage).to receive(:publish)
    end

    context 'when the version exists' do
      it 'creates new workflows' do
        expect do
          put :deprecated_create, body: request_data, params: { repo: repository, druid: druid, workflow: workflow, format: :xml }
        end.to change(WorkflowStep, :count).by(16)

        expect(SendUpdateMessage).to have_received(:publish).with(druid: druid)
      end

      context 'and ignores bad request data' do
        let(:request_data) { '<foo></foo>' }
        it 'returns a 400 error' do
          expect do
            put :deprecated_create, body: request_data, params: { repo: repository, druid: druid, workflow: workflow, format: :xml }
          end.to change(WorkflowStep, :count).by(16)
        end
      end
    end

    context "when the version doesn't exist" do
      let(:version_client) { double }

      before do
        allow(version_client).to receive(:current).and_raise(Dor::Services::Client::NotFoundResponse)
      end

      it 'creates new workflows' do
        expect do
          put :deprecated_create, body: request_data, params: { repo: repository, druid: druid, workflow: workflow, format: :xml }
        end.to change(WorkflowStep, :count).by(16)

        expect(SendUpdateMessage).to have_received(:publish).with(druid: druid)
      end
    end
  end

  describe 'POST create' do
    let(:druid) { 'druid:bb123bb1234' }
    let(:workflow) { 'accessionWF' }
    let(:lane_id) { 'foo' }

    before do
      allow(SendUpdateMessage).to receive(:publish)
    end

    context 'when the version exists' do
      it 'creates new workflows' do
        expect do
          post :create, params: { druid: druid, workflow: workflow, format: :xml }
        end.to change(WorkflowStep, :count).by(16)
        expect(WorkflowStep.last.lane_id).to eq('default')
        expect(SendUpdateMessage).to have_received(:publish).with(druid: druid)
      end

      it 'sets the lane id' do
        post :create, params: { druid: druid, workflow: workflow, lane_id: lane_id, format: :xml }
        expect(WorkflowStep.last.lane_id).to eq(lane_id)
      end

      context 'and the request is bad' do
        let(:workflow) { 'xaccessionWF' }
        it 'returns a 400 error' do
          expect do
            post :create, params: { druid: druid, workflow: workflow, format: :xml }
          end.not_to change(WorkflowStep, :count)
          expect(response.status).to eq 400
        end
      end
    end

    context "when the version doesn't exist" do
      let(:version_client) { double }

      before do
        allow(version_client).to receive(:current).and_raise(Dor::Services::Client::NotFoundResponse)
      end

      it 'creates new workflows' do
        expect do
          post :create, params: { druid: druid, workflow: workflow, format: :xml }
        end.to change(WorkflowStep, :count).by(16)

        expect(SendUpdateMessage).to have_received(:publish).with(druid: druid)
      end
    end
  end
end
