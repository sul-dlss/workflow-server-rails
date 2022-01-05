# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails', '~> 6.1.0'

gem 'bootsnap', '>= 1.1.0', require: false
gem 'bunny', '~> 2.17'
gem 'config', '~> 2.0'
gem 'druid-tools'
gem 'honeybadger', '~> 4.1'
gem 'jbuilder', '~> 2.5'
gem 'lograge'
gem 'okcomputer'
gem 'pg'
gem 'pry-rails' # useful for prod debugging
gem 'puma', '~> 5.3' # app server
gem 'resque', '~> 2.0'
gem 'stomp', '~> 1.4'
gem 'whenever', require: false

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'equivalent-xml'
  gem 'factory_bot_rails'
  gem 'rspec_junit_formatter'
  gem 'rspec-rails', '~> 5.0'
  gem 'rubocop', '~> 1.0'
  # Codeclimate is not compatible with 0.18+. See https://github.com/codeclimate/test-reporter/issues/413
  gem 'simplecov', '~> 0.17.1'
end

group :development do
  gem 'capistrano-passenger', require: false
  gem 'capistrano-rails', require: false
  gem 'dlss-capistrano', require: false
  gem 'listen'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
