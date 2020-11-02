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

OkComputer::Registry.register 'feature-tables-have-data', TablesHaveDataCheck.new
