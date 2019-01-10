# frozen_string_literal: true

# Models a process that occurred for a digital object. Basically a log entry.
class WorkflowStep < ApplicationRecord
  validates :druid, presence: true
  validates :datastream, presence: true
  validates :process, presence: true
  validates :version, presence: true

  ##
  # Serialize a WorkflowStep as a milestone
  # @param [Nokogiri::XML::Builder] xml
  # @return [Nokogiri::XML::Builder::NodeBuilder]
  def as_milestone(xml)
    xml.milestone(lifecycle,
                  date: updated_at.to_time.iso8601,
                  version: version)
  end

  ##
  # Serialize a WorkflowStep as a process
  # @param [Nokogiri::XML::Builder] xml
  # @return [Nokogiri::XML::Builder::NodeBuilder]
  def as_process(xml)
    xml.process(version: version,
                priority: priority,
                note: note,
                lifecycle: lifecycle,
                laneId: lane_id,
                elapsed: elapsed,
                attempts: attempts,
                datetime: created_at.to_time.iso8601,
                status: status,
                name: process)
  end
end
