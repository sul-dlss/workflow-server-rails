# frozen_string_literal: true

Rails.application.routes.draw do
  scope ':repo/objects/:druid', constraints: { druid: %r{[^\/]+} }, defaults: { format: :xml } do
    get 'lifecycle', to: 'workflows#lifecycle'

    resources :workflows, only: %i[show index destroy], param: :workflow do
      collection do
        # Create should be a POST, but this is what the Java WFS app did.
        put ':workflow', to: 'workflows#create'
        put ':workflow/:process', to: 'workflows#update'
      end
    end
  end

  get '/workflow_archive',
      to: 'workflows#archive',
      constraints: { druid: %r{[^\/]+} },
      defaults: { format: :xml }

  resource :workflow_queue, only: [] do
    collection do
      get 'lane_ids'
    end
  end
end
