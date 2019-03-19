# frozen_string_literal: true

# Models a process that occurred for a digital object. Basically a log entry.
class WorkflowStep < ApplicationRecord
  validates :druid, presence: true
  validates :workflow, presence: true
  validates :process, presence: true
  validates :version, presence: true

  scope :lifecycle, -> { where.not(lifecycle: nil) }
  scope :incomplete, -> { where.not(status: %w[completed skipped]) }
  scope :complete, -> { where(status: %w[completed skipped]) }
  scope :waiting, -> { where(status: 'waiting') }
  scope :active, -> { where(active_version: true) }

  scope :for_version, ->(version) { where(version: version) }
  ##
  # Serialize a WorkflowStep as a milestone
  # @param [Nokogiri::XML::Builder] xml
  # @return [Nokogiri::XML::Builder::NodeBuilder]
  def as_milestone(xml)
    xml.milestone(lifecycle,
                  date: updated_at.to_time.iso8601,
                  version: version)
  end

  # rubocop:disable Metrics/MethodLength
  def attributes_for_process
    {
      version: version,
      priority: priority,
      note: note,
      lifecycle: lifecycle,
      laneId: lane_id,
      elapsed: elapsed,
      attempts: attempts,
      datetime: updated_at.to_time.iso8601,
      status: status,
      name: process
    }.tap do |attr|
      attr[:errorMessage] = error_msg if error_msg
    end
  end
  # rubocop:enable Metrics/MethodLength
end
