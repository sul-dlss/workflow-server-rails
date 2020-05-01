# frozen_string_literal: true

server 'workflow-service-qa.stanford.edu', user: 'workflow', roles: %w[web app db]

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'
