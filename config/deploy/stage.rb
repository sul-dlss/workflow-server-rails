# frozen_string_literal: true

server 'workflow-service-stage.stanford.edu', user: 'workflow', roles: %w[web app db]

set :rails_env, 'production'
