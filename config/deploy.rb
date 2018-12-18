# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, "workflow-server-rails"
set :repo_url, 'https://github.com/sul-dlss-labs/workflow-server-rails.git'

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :deploy_to, "/opt/app/workflow/#{fetch(:application)}"


set :linked_dirs, %w(log tmp/pids tmp/cache tmp/sockets vendor/bundle)
set :linked_files, %w(config/database.yml config/honeybadger.yml)

# honeybadger_env otherwise defaults to rails_env
set :honeybadger_env, fetch(:stage)

# update shared_configs before restarting app
before 'deploy:restart', 'shared_configs:update'
