# frozen_string_literal: true

#
# You may set the environment variable SETTINGS__RABBITMQ_ENABLED=false to
# prevent sending any RabbitMQ messages.
class SendUpdateMessage
  def self.publish(step:)
    SendRabbitmqMessage.publish(step:) if Settings.rabbitmq.enabled
  end
end
