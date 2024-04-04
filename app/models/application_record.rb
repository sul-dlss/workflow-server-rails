# frozen_string_literal: true

# Base ApplicationRecord Class
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
