# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'workflows/index' do
  let(:druid) { 'druid:abc123' }
  let(:repo) { 'dor' }
  let(:params) { { druid: druid, repo: repo } }
  it 'renders a workflows document' do
    FactoryBot.create(
      :workflow_step,
      repository: repo,
      druid: druid,
      workflow: 'accessionWF'
    )
    @processes = WorkflowStep.all.group_by(&:workflow)

    render template: 'workflows/index', locals: { params: params }
    doc = Nokogiri::XML.parse(rendered)
    expect(doc.at_xpath('//workflow')).to include(
      %w[repository dor],
      %w[objectId druid:abc123],
      %w[id accessionWF]
    )
    expect(doc.at_xpath('//process')).to include(
      ['version', /1/],
      ['priority', /0/],
      ['note', ''],
      ['lifecycle', ''],
      %w[laneId default],
      ['elapsed', ''],
      ['attempts', /0/],
      ['datetime', //],
      ['status', ''],
      %w[name start-accession]
    )
  end
end
