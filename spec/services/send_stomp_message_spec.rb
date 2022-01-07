# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SendStompMessage do
  let(:druid) { 'druid:bb123bb1234' }

  describe '#publish' do
    subject(:publish) do
      sender.publish(message: mock_message)
    end

    let(:sender) { described_class.new(druid: druid) }
    let(:mock_message) { instance_double(described_class::UpdateMessage, to_xml: 'hello') }
    let(:mock_client) { instance_double(Stomp::Client, publish: true, close: true) }

    before do
      allow(Stomp::Client).to receive(:new).and_return(mock_client)
      publish
    end

    it 'sends a message' do
      expect(mock_client).to have_received(:publish)
        .with('/topic/fedora.apim.update',
              'hello',
              'methodName' => 'modifyObject', 'pid' => 'druid:bb123bb1234')
    end
  end

  describe described_class::UpdateMessage do
    let(:instance) { described_class.new(druid: druid) }

    describe '#to_xml' do
      subject { instance.to_xml }

      before do
        allow(instance).to receive(:timestamp).and_return('2019-01-25T15:18:32Z')
        allow(SecureRandom).to receive(:uuid).and_return('d087b3fd-0144-4114-a065-5194088c9ac8')
      end

      it {
        is_expected.to eq <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <entry xmlns="http://www.w3.org/2005/Atom"
                  xmlns:fedora-types="http://www.fedora.info/definitions/1/0/types/"
                  xmlns:xsd="http://www.w3.org/2001/XMLSchema">
              <id>urn:uuid:d087b3fd-0144-4114-a065-5194088c9ac8</id>
              <updated>2019-01-25T15:18:32Z</updated>
              <author>
                  <name>fedoraAdmin</name>
                  <uri>https://dor-test.stanford.edu</uri>
              </author>
              <title type="text">modifyObject</title>
              <summary type="text">druid:bb123bb1234</summary>
              <content type="text">2019-01-25T15:18:32Z</content>
          </entry>
        XML
      }
    end
  end
end
