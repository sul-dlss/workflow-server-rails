# frozen_string_literal: true

##
# Parsing Process creation request
class ProcessParser
  attr_reader :process

  ##
  # @param [Nokogiri::XML::Element] process
  def initialize(process)
    @process = process
  end

  def name
    process.attr('name')
  end

  def status
    process.attr('status')
  end

  def lane_id
    process.attr('laneId')
  end

  def lifecycle
    process.attr('lifecycle')
  end
end
