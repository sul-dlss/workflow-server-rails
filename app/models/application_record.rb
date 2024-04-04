# frozen_string_literal: true

# Base ApplicationRecord Class
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  validate :druid_is_valid

  # ensure we have a valid druid with prefix
  def druid_is_valid
    errors.add(:druid, 'is not valid') unless valid_druid?
  end

  # @return [boolean]
  def valid_druid?
    DruidTools::Druid.valid?(druid, true) && druid.starts_with?('druid:')
  end
end
