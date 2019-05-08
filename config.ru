# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.
require_relative 'config/environment'
require 'resque/server'

run Rack::URLMap.new(
  '/' => Rails.application,
  '/resque' => Resque::Server.new)
