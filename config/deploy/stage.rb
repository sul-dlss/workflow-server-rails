# frozen_string_literal: true

server 'workflow-service-stage.stanford.edu', user: 'workflow', roles: %w[web app]

Capistrano::OneTimeKey.generate_one_time_key!
