# frozen_string_literal: true

# Send a message to a RabbitMQ exchange that an item has been updated.
class SendRabbitmqMessage
  def self.publish(step:)
    Rails.logger.info "Publishing Rabbitmq Message for #{step.druid}: #{step.process}.#{step.status}"
    new(step:).publish
    Rails.logger.info "Published Rabbitmq Message for #{step.druid}: #{step.process}.#{step.status}"
  end

  def initialize(step:, channel: $rabbitmq_channel) # rubocop:disable Style/GlobalVars
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
