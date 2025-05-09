# frozen_string_literal: true

server 'workflow-service-qa.stanford.edu', user: 'workflow', roles: %w[web app db]

set :rails_env, 'production'
