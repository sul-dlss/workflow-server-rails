# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'workflows/index' do
  let(:druid) { 'druid:bb123bb1234' }

  let(:step) do
    FactoryBot.build(
      :workflow_step,
      druid:,
      updated_at: Date.today,
      workflow: 'accessionWF'
    )
  end

  before do
    @workflow = Workflow.new(druid:, name: 'accessionWF', steps: [step])
  end

  it 'renders a workflows document' do
    render template: 'workflows/show'
    doc = Nokogiri::XML.parse(rendered)
    expect(doc.at_xpath('//workflow')).to include(
      %w[objectId druid:bb123bb1234],
      %w[id accessionWF]
    )
    expect(doc.at_xpath('//process')).to include(
      ['version', /1/],
      ['note', ''],
      ['lifecycle', ''],
      %w[laneId default],
      ['elapsed', ''],
      ['attempts', /0/],
      ['datetime', //],
      %w[status waiting],
      %w[name start-accession]
    )
  end
end
