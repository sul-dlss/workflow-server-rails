ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.

# We aren't using cookies in this application, so just generate a value at startup.
ENV['SECRET_KEY_BASE'] ||= SecureRandom.hex(64)
