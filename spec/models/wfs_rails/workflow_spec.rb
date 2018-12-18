require 'rails_helper'

RSpec.describe WfsRails::Workflow do
  describe '.table_name' do
    subject { described_class.table_name }
    it { is_expected.to eq 'workflow' }
  end
end
