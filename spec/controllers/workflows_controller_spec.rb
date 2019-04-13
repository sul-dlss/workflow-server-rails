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

    before do
      allow(SendUpdateMessage).to receive(:publish)
    end

    context 'when the version exists' do
      it 'creates new workflows' do
        expect do
          put :create, body: request_data, params: { repo: repository, druid: druid, workflow: workflow, format: :xml }
        end.to change(WorkflowStep, :count)
          .by(Nokogiri::XML(workflow_create).xpath('//process').count)

        expect(SendUpdateMessage).to have_received(:publish).with(druid: druid)
      end

      context 'and the request is bad' do
        let(:request_data) { '<foo></foo>' }
        it 'returns a 400 error' do
          expect do
            put :create, body: request_data, params: { repo: repository, druid: druid, workflow: workflow, format: :xml }
          end.not_to change(WorkflowStep, :count)
          expect(response.status).to eq 400
        end
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

        expect(SendUpdateMessage).to have_received(:publish).with(druid: druid)
      end
    end
  end
end
