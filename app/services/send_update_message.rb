# frozen_string_literal: true

#
# You may set the environment variable SETTINGS__ENABLE_STOMP=false to
# prevent sending any Stomp messages.
class SendUpdateMessage
  def self.publish(step:)
    SendStompMessage.publish(druid: step.druid) if Settings.enable_stomp
    SendRabbitmqMessage.publish(step: step) if Settings.rabbitmq.enabled
  end
end
