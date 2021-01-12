# frozen_string_literal: true

# Send a message to a RabbitMQ exchange that an item has been updated.
class SendRabbitmqMessage
  def self.publish(step:)
    Rails.logger.info "Publishing Rabbitmq Message for #{step.druid}"
    new(step: step, channel: channel).publish
    Rails.logger.info "Published Rabbitmq Message for #{step.druid}"
  end

  def self.channel
    @channel ||= connection.create_channel
  end

  # We are using default settings here
  # The `Bunny.new(...)` is a place to
  # put any specific RabbitMQ settings
  # like host or port
  def self.connection
    @connection ||= Bunny.new(hostname: Settings.rabbitmq.hostname,
                              vhost: Settings.rabbitmq.vhost,
                              username: Settings.rabbitmq.username,
                              password: Settings.rabbitmq.password).tap(&:start)
  end

  def initialize(step:, channel:)
    @step = step
    @channel = channel
  end

  def publish
    message = { druid: step.druid, action: 'workflow updated' }
    exchange = channel.topic('sdr.workflow')
    exchange.publish(message.to_json, routing_key: "#{step.process}.#{step.status}")
  end

  private

  attr_reader :step, :channel
end
