# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'workflows/archive' do
  let(:druid) { 'druid:ab123ab1234' }
  let(:repo) { 'dor' }
  let(:params) { { druid: druid, repo: repo } }
  it 'renders a workflows document' do
    FactoryBot.create(
      :workflow_step,
      repository: repo,
      druid: druid
    )
    @objects = WorkflowStep.all.count

    render template: 'workflows/archive', locals: { params: params }
    doc = Nokogiri::XML.parse(rendered)
    expect(doc.at_xpath('//objects')).to include ['count', /1/]
  end
end
