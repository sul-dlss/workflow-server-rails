# frozen_string_literal: true

##
# Parsing Process creation request
class ProcessParser
  attr_reader :process_element

  PROCESS_ATTRIBUTES = %i[
    process
    status
    lane_id
    lifecycle
    error_msg
    error_txt
    note
    elapsed
  ].freeze

  ##
  # @param [Nokogiri::XML::Element] process_element
  def initialize(process_element)
    @process_element = process_element
  end

  def to_h
    PROCESS_ATTRIBUTES.each_with_object({}) do |attribute, hash|
      hash[attribute] = public_send(attribute)
    end
  end

  def process
    process_element.attr('name')
  end

  def status
    process_element.attr('status')
  end

  def lane_id
    process_element.attr('laneId') || 'default'
  end

  def lifecycle
    process_element.attr('lifecycle')
  end

  def error_msg
    process_element.attr('errorMessage')
  end

  def error_txt
    process_element.attr('errorText')
  end

  def note
    process_element.attr('note')
  end

  def elapsed
    process_element.attr('elapsed').to_f
  end
end
