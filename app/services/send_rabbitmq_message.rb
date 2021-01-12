# frozen_string_literal: true

# Send a message to a RabbitMQ exchange that an item has been updated.
class SendRabbitmqMessage
  def self.publish(druid:)
    Rails.logger.info "Publishing Rabbitmq Message for #{druid}"
    new(druid: druid, channel: channel).publish
    Rails.logger.info "Published Rabbitmq Message for #{druid}"
  end

  def self.channel
    @channel ||= connection.create_channel
  end

  # We are using default settings here
  # The `Bunny.new(...)` is a place to
  # put any specific RabbitMQ settings
  # like host or port
  def self.connection
    @connection ||= Bunny.new(hostname: Settings.rabbitmq.hostname).tap(&:start)
  end

  def initialize(druid:, channel:)
    @druid = druid
    @channel = channel
  end

  def publish
    message = { druid: druid, action: 'workflow updated' }
    # grab the fanout exchange
    exchange = channel.fanout("blog.#{exchange}")
    # and simply publish message
    exchange.publish(message.to_json)
  end

  private

  attr_reader :druid, :channel
end
