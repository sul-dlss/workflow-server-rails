# frozen_string_literal: true

#
# You may set the environment variable SETTINGS__ENABLE_STOMP=false to
# prevent sending any Stomp messages.
class SendUpdateMessage
  def self.publish(druid:)
    SendStompMessage.publish(druid: druid) if Settings.enable_stomp
    SendRabbitmqMessage.publish(druid: druid) if Settings.rabbitmq.enabled
  end
end
