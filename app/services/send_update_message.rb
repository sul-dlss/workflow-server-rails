# frozen_string_literal: true

# Send a message to a STOMP topic that an item has been updated.
# This message mimics the message that Fedora sends to the same topic.
# A consumer of this queue, when seeing the messages, reindexes the objects into
# Argo's Solr. It's useful for us to mimic Fedora's messages, because the topic
# is set to deduplicate messages, so that many quick updates in succession don't
# necessarily trigger multiple reindexes which are expensive in terms of
# number of service calls.
class SendUpdateMessage
  TOPIC_NAME = '/topic/fedora.apim.update'

  def self.publish(druid:)
    new(druid: druid).publish
  end

  def initialize(druid:)
    @druid = druid
  end

  def publish(message: build_message)
    headers = { 'pid' => druid, 'methodName' => 'modifyObject' }
    client.publish(TOPIC_NAME, message.to_xml, headers)
  end

  private

  attr_reader :druid

  def build_message
    UpdateMessage.new(druid: druid)
  end

  def client
    Stomp::Client.new(hosts: parse_failover_url(Settings.messaging.uri),
                      reliable: true,
                      start_timeout: 1,
                      connect_timeout: 1,
                      connread_timeout: 1,
                      parse_timeout: 1)
  end

  def parse_failover_url(url)
    md = Stomp::FAILOVER_REGEX.match(url)
    raise ArgumentError, "#{url} does not match the Stomp::FAILOVER_REGEX" unless md

    host_match = %r{stomp(\+ssl)?://#{Stomp::URL_REPAT}}
    url.scan(host_match).map do |match|
      { ssl: match[0] == '+ssl',
        login: match[3] || '',
        passcode: match[4] || '',
        host: match[5],
        port: match[6].to_i }
    end
  end

  # @private
  class UpdateMessage
    def initialize(druid:)
      @druid = druid
    end

    def to_xml
      <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <entry xmlns="http://www.w3.org/2005/Atom"
                xmlns:fedora-types="http://www.fedora.info/definitions/1/0/types/"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema">
            <id>urn:uuid:#{uuid}</id>
            <updated>#{timestamp}</updated>
            <author>
                <name>fedoraAdmin</name>
                <uri>#{fedora_url}</uri>
            </author>
            <title type="text">modifyObject</title>
            <summary type="text">#{druid}</summary>
            <content type="text">#{timestamp}</content>
        </entry>
      XML
    end

    private

    attr_reader :druid
    def uuid
      SecureRandom.uuid
    end

    def timestamp
      @timestamp ||= Time.now.utc.iso8601
    end

    def fedora_url
      Settings.messaging.fedora_url
    end
  end
end
