# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails', '~> 7.2.0'

gem 'bootsnap', '>= 1.1.0', require: false
gem 'bunny', '~> 2.17'
gem 'config'
gem 'druid-tools'
gem 'honeybadger'
gem 'jbuilder', '~> 2.5'
gem 'lograge'
gem 'okcomputer'
gem 'pg'
gem 'pry' # make it possible to use pry for IRB (in prod debugging)
gem 'puma'
gem 'sidekiq', '~> 7.0'
gem 'whenever', require: false

source 'https://gems.contribsys.com/' do
  gem 'sidekiq-pro'
end

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'equivalent-xml'
  # NOTE: factory_bot_rails >= 6.3.0 requires env/test.rb to have config.factory_bot.reject_primary_key_attributes = false
  gem 'factory_bot_rails'
  gem 'rspec_junit_formatter'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-capybara'
  gem 'rubocop-factory_bot'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'rubocop-rspec_rails'
  gem 'simplecov'
end

group :development do
  gem 'capistrano-passenger', require: false
  gem 'capistrano-rails', require: false
  gem 'dlss-capistrano', require: false
end
