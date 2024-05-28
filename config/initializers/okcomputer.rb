# frozen_string_literal: true

OkComputer.mount_at = 'status'

# spot check db for data loss
class TablesHaveDataCheck < OkComputer::Check
  def check
    msg = [
      WorkflowStep
    ].map { |klass| table_check(klass) }.join(' ')
    mark_message msg
  end

  private

  # @return [String] message
  def table_check(klass)
    # has at least 1 record
    return "#{klass.name} has data." if klass.any?

    mark_failure
    "#{klass.name} has no data."
  rescue => e # rubocop:disable Style/RescueStandardError
    mark_failure
    "#{e.class.name} received: #{e.message}."
  end
end

# check the depth of the ocr queue
class OcrQueueDepthCheck < OkComputer::Check
  MAX_OCR_WAITING = 20 # alert if we have more than this number of objects waiting in ocrWF:ocr-create

  def check
    num_ocr_waiting = WorkflowStep.where(workflow: 'ocrWF', process: 'ocr-create').active.waiting.size

    msg = "ocrWF:ocr-create step has #{num_ocr_waiting} waiting"
    if num_ocr_waiting > MAX_OCR_WAITING
      mark_failure
      msg += " (more than #{MAX_OCR_WAITING})"
    end

    mark_message msg
  end
end

OkComputer::Registry.register 'feature-tables-have-data', TablesHaveDataCheck.new
OkComputer::Registry.register 'ocr_queue_depth', OcrQueueDepthCheck.new

if Settings.rabbitmq.enabled
  OkComputer::Registry.register 'rabbit',
                                OkComputer::RabbitmqCheck.new(hostname: Settings.rabbitmq.hostname,
                                                              vhost: Settings.rabbitmq.vhost,
                                                              username: Settings.rabbitmq.username,
                                                              password: Settings.rabbitmq.password)
end
