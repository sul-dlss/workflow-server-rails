# frozen_string_literal: true

Rails.application.routes.draw do
  scope 'objects/:druid', constraints: { druid: %r{[^/]+} }, defaults: { format: :xml } do
    get 'lifecycle', to: 'workflows#lifecycle'
    delete 'workflows', to: 'steps#destroy_all'

    resources :workflows, only: %i[show index destroy], param: :workflow do
      collection do
        post ':workflow', to: 'workflows#create'
        put ':workflow/:process', to: 'steps#update'
        # made a post because it conflicts with the line above when a put request
        post ':workflow/skip-all', to: 'steps#skip_all'
      end
    end
  end

  resources :workflow_templates, only: %i[show index], defaults: { format: :json }

  resource :workflow_queue, only: :show, defaults: { format: :xml } do
    collection do
      get 'lane_ids'
      get 'all_queued'
    end
  end
end
