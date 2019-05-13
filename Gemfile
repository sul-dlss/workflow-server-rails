# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.3'

gem 'rails', '~> 5.2.0'

gem 'activerecord-import' # we can remove this after we've migrated the data
gem 'bootsnap', '>= 1.1.0', require: false
gem 'config', '~> 1.7'
gem 'dor-services-client', '~> 1.2'
gem 'honeybadger', '~> 4.1'
gem 'jbuilder', '~> 2.5'
gem 'okcomputer'
gem 'pg'
gem 'puma', '~> 3.11'
gem 'resque', '~> 2.0'
gem 'stomp', '~> 1.4'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'dor-workflow-service', '~> 2.3'
  gem 'equivalent-xml'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-performance'
end

group :development do
  gem 'capistrano-passenger', require: false
  gem 'capistrano-rails', require: false
  gem 'dlss-capistrano', require: false
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
