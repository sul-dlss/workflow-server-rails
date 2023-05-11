# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'workflows/lifecycle' do
  let(:druid) { 'druid:bb123bb1234' }
  let(:params) { { druid: } }

  it 'renders a workflows document' do
    FactoryBot.create(
      :workflow_step,
      druid:,
      workflow: 'accessionWF'
    )
    @objects = WorkflowStep.all

    render template: 'workflows/lifecycle', locals: { params: }
    doc = Nokogiri::XML.parse(rendered)
    expect(doc.at_xpath('//lifecycle')).to include %w[objectId druid:bb123bb1234]
    expect(doc.at_xpath('//milestone')).to include(
      ['version', /1/],
      ['date', //]
    )
  end
end
