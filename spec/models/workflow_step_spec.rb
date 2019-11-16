# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkflowStep do
  subject(:step) do
    FactoryBot.create(
      :workflow_step,
      workflow: 'accessionWF',
      process: 'start-accession',
      lifecycle: 'submitted'
    )
  end
  context 'with required values' do
    it 'is valid' do
      expect(subject.valid?).to be true
    end
  end
  context 'without required values' do
    subject { described_class.create }
    it 'is not valid' do
      expect(subject.valid?).to be false
    end
  end
  context 'without valid status' do
    it 'is not valid if the status is nil' do
      expect(subject.valid?).to be true
      subject.status = nil
      expect(subject.valid?).to be false
    end
    it 'is not valid if the status is a bogus value' do
      expect(subject.valid?).to be true
      subject.status = 'bogus'
      expect(subject.valid?).to be false
    end
  end
  context 'duplicate step for the same process/version' do
    it 'is not valid if the step already exists for the same druid/workflow/version' do
      dupe_step = described_class.new(
        druid: subject.druid,
        workflow: subject.workflow,
        process: subject.process,
        version: subject.version,
        status: 'completed',
        repository: 'dor'
      )
      expect(dupe_step.valid?).to be false
      expect(dupe_step.errors.messages).to include(process: ['has already been taken'])
    end
  end
  context 'without valid workflow name' do
    it 'is not possible to create a new workflow step for a non-existent or missing workflow value' do
      bogus_workflow = described_class.new(
        druid: subject.druid,
        workflow: 'bogusWF',
        process: subject.process,
        version: subject.version,
        status: subject.status,
        repository: subject.repository
      )
      expect(bogus_workflow.valid?).to be false
      expect(bogus_workflow.errors.messages).to include(workflow: ['is not valid'])
      bogus_workflow.workflow = nil
      expect(bogus_workflow.valid?).to be false
    end
  end
  context 'without valid process name' do
    it 'is not possible to create a new workflow step for a non-existent or missing process value' do
      bogus_process = described_class.new(
        druid: subject.druid,
        workflow: subject.workflow,
        process: 'bogus-step',
        version: subject.version,
        status: subject.status,
        repository: subject.repository
      )
      expect(bogus_process.valid?).to be false
      expect(bogus_process.errors.messages).to include(process: ['is not valid'])
      bogus_process.process = nil
      expect(bogus_process.valid?).to be false
    end
  end
  context 'without valid version' do
    it 'is not valid if the version is nil' do
      expect(subject.valid?).to be true
      subject.version = nil
      expect(subject.valid?).to be false
    end
    it 'is not valid if the version is not an integer' do
      expect(subject.valid?).to be true
      subject.version = 'bogus'
      expect(subject.valid?).to be false
      subject.version = 4.3
      expect(subject.valid?).to be false
      subject.version = ''
      expect(subject.valid?).to be false
    end
  end
  describe '#as_milestone' do
    builder = {}
    before do
      builder = Nokogiri::XML::Builder.new do |xml|
        subject.as_milestone(xml)
      end
    end
    let(:parsed_xml) { Nokogiri::XML(builder.to_xml) }
    it 'serializes a Workflow as a milestone' do
      expect(parsed_xml.at_xpath('//milestone'))
        .to include ['date', //], ['version', /1/]
      expect(parsed_xml.at_xpath('//milestone').content).to eq 'submitted'
    end
  end

  describe '#attributes_for_process' do
    subject { step.attributes_for_process }
    it {
      is_expected.to include(
        version: 1,
        note: nil,
        lifecycle: 'submitted',
        laneId: 'default',
        elapsed: nil,
        attempts: 0,
        datetime: String,
        status: 'waiting',
        name: 'start-accession'
      )
    }
  end
end
