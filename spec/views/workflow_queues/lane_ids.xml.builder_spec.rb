# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'workflow_queues/lane_ids' do
  it 'renders a workflows document' do
    @lanes = %w[foo bar]
    render
    doc = Nokogiri::XML.parse(rendered)
    expect(doc.at_xpath('//lanes/lane[1]/@id').value).to eq 'foo'
    expect(doc.at_xpath('//lanes/lane[2]/@id').value).to eq 'bar'
  end
end
