# frozen_string_literal: true

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.

# We aren't using cookies in this application, so just generate a value at startup.
ENV['SECRET_KEY_BASE'] ||= SecureRandom.hex(64)

# Load Resque configuration and controller
require 'resque'
begin
  REDIS_HOSTNAME = ENV['REDIS_HOSTNAME'] || 'localhost' unless defined? REDIS_HOSTNAME
  REDIS_PORT = ENV['REDIS_PORT'] || '6379' unless defined? REDIS_PORT
  REDIS_DB = ENV['REDIS_DB'] || 'resque' unless defined? REDIS_DB
  REDIS_NAMESPACE = ENV['REDIS_NAMESPACE'] || ENV['RAILS_ENV'] || 'development' unless defined? REDIS_NAMESPACE
  redis = Redis.new(host: REDIS_HOSTNAME, port: REDIS_PORT, thread_safe: true, db: REDIS_DB)
  Resque.redis = Redis::Namespace.new(REDIS_NAMESPACE, redis: redis)
end
