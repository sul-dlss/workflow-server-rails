# frozen_string_literal: true

Rails.application.routes.draw do
  scope ':repo/objects/:druid', constraints: { druid: %r{[^\/]+} }, defaults: { format: :xml } do
    get 'lifecycle', to: 'workflows#lifecycle'
    post 'versionClose', to: 'versions#close'

    # NOTE: the index route /dor/objects/:druid/workflows is encoded in the dsLocation of the workflows
    # datastream (external type) for all of our Fedora 3 objects, so we shouldn't
    # change this endpoint until we get rid of the workflows as a datastream.
    resources :workflows, only: %i[show index destroy], param: :workflow do
      collection do
        # Create should be a POST, but this is what the Java WFS app did.
        put ':workflow', to: 'workflows#deprecated_create'
        put ':workflow/:process', to: 'steps#update' # deprecated
        get ':workflow/:process', to: 'steps#show'
      end
    end
  end

  scope 'objects/:druid', constraints: { druid: %r{[^\/]+} }, defaults: { format: :xml } do
    get 'lifecycle', to: 'workflows#lifecycle'
    delete 'workflows', to: 'steps#destroy_all'
    post 'versionClose', to: 'versions#close'

    resources :workflows, only: %i[show index], param: :workflow do
      collection do
        post ':workflow', to: 'workflows#create'
        put ':workflow/:process', to: 'steps#update'
      end
    end
  end

  resources :workflow_templates, only: %i[show index], defaults: { format: :json }

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
