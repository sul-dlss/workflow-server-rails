# frozen_string_literal: true

Rails.application.routes.draw do
  scope ':repo/objects/:druid', constraints: { druid: %r{[^\/]+} }, defaults: { format: :xml } do
    get 'lifecycle', to: 'workflows#lifecycle'
    post 'versionClose', to: 'versions#close'

    resources :workflows, only: %i[show index destroy], param: :workflow do
      collection do
        # Create should be a POST, but this is what the Java WFS app did.
        put ':workflow', to: 'workflows#create'
        put ':workflow/:process', to: 'steps#update'
      end
    end
  end

  scope 'objects/:druid', constraints: { druid: %r{[^\/]+} }, defaults: { format: :xml } do
    resources :workflows, only: %i[index], param: :workflow
  end

  get '/workflow_archive',
      to: 'workflows#archive',
      constraints: { druid: %r{[^\/]+} },
      defaults: { format: :xml }

  resource :workflow_queue, only: :show, defaults: { format: :xml } do
    collection do
      get 'lane_ids'
      get 'all_queued'
    end
  end
end
