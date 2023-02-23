# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails', '~> 7.0.0'

gem 'bootsnap', '>= 1.1.0', require: false
gem 'bunny', '~> 2.17'
gem 'config', '~> 2.0'
gem 'druid-tools'
gem 'honeybadger', '~> 4.1'
gem 'jbuilder', '~> 2.5'
gem 'lograge'
gem 'okcomputer'
gem 'pg'
gem 'pry' # make it possible to use pry for IRB (in prod debugging)
gem 'puma', '~> 5.3' # app server
gem 'sidekiq', '~> 6.4'
gem 'whenever', require: false

source 'https://gems.contribsys.com/' do
  gem 'sidekiq-pro'
end

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'equivalent-xml'
  gem 'factory_bot_rails'
  gem 'rspec_junit_formatter'
  gem 'rspec-rails', '~> 5.0'
  gem 'rubocop', '~> 1.0'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'simplecov'
end

group :development do
  gem 'capistrano-passenger', require: false
  gem 'capistrano-rails', require: false
  gem 'dlss-capistrano', require: false
end
