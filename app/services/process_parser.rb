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

  # These properties should be updated to nil if they are not passed.
  MUTABLE_PROPERTIES = %i[
    status
    error_msg
  ].freeze

  ##
  # @param [Nokogiri::XML::Element] process_element
  def initialize(process_element)
    @process_element = process_element
  end

  # Convert the xml to a hash suitable for creating or updating the model.
  # This is tricky, because some properties are mutable (e.g. status and error_msg)
  # and others are not.  The lack of an error_msg means we should clear out the message
  # but the lack of a lifecycle, should not clear anything.
  def to_h
    PROCESS_ATTRIBUTES.each_with_object({}) do |attribute, hash|
      value = public_send(attribute)
      next if value.nil? && !MUTABLE_PROPERTIES.include?(attribute)

      hash[attribute] = value
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
