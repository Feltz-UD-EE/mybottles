Rails.application.routes.draw do
  devise_for :users, skip: :registrations
  root "public/home#index"
  get "dashboard", to: "home#index", as: :dashboard

  resource :profile, only: %i[ show edit update ]
  resources :invitations, only: %i[ new create ]

  namespace :public do
    resources :producers, only: %i[ index show ]
    resources :wines, only: %i[ index show ]
    resources :regions, only: %i[ index show ]
  end

  namespace :review do
    root "dashboard#index"
    resources :producers, controller: :community_records, type: "Producer", only: %i[ index show ] do
      patch :approve, on: :member
      patch :reject, on: :member
      patch :merge, on: :member
    end
    resources :wines, controller: :community_records, type: "Wine", only: %i[ index show ] do
      patch :approve, on: :member
      patch :reject, on: :member
      patch :merge, on: :member
    end
    resources :vintages, controller: :community_records, type: "Vintage", only: %i[ index show ] do
      patch :approve, on: :member
      patch :reject, on: :member
      patch :merge, on: :member
    end
    resources :grapes, controller: :community_records, type: "Grape", only: %i[ index show ] do
      patch :approve, on: :member
      patch :reject, on: :member
      patch :merge, on: :member
    end
    resources :grape_synonyms, controller: :community_records, type: "GrapeSynonym", only: %i[ index show ] do
      patch :approve, on: :member
      patch :reject, on: :member
      patch :merge, on: :member
    end
    resources :appellation_grapes, controller: :community_records, type: "AppellationGrape", only: %i[ index show ] do
      patch :approve, on: :member
      patch :reject, on: :member
      patch :merge, on: :member
    end
    resources :proposed_changes, only: %i[ show ] do
      patch :approve, on: :member
      patch :reject, on: :member
      patch :supersede, on: :member
    end
  end

  namespace :user_review do
    root "stats#index"
    get "trusted_users", to: "users#index", defaults: { trust_level: "Trusted" }, as: :trusted_users
    get "basic_users", to: "users#index", defaults: { trust_level: "Basic" }, as: :basic_users
    resources :users, only: %i[ show ] do
      patch :promote, on: :member
      patch :demote, on: :member
    end
    resource :stats, only: %i[ show ], controller: :stats
    resources :all_users, only: %i[ index ] do
      patch :promote, on: :member
      patch :demote, on: :member
    end
  end

  resources :user_trust_events, only: [] do
    patch :dismiss, on: :member
  end

  get "about", to: "static#about"
  get "legal", to: "static#legal"
  get "credits", to: "static#credits"
  get "signup", to: "static#signup"

  resources :producers
  resources :wines
  resources :vintages
  resources :grapes
  resources :grape_synonyms, only: %i[ create edit update destroy ]
  resources :appellation_grapes, only: %i[ edit update destroy ]
  resources :bottles do
    get :label, on: :member
  end
  resources :cellars
  resources :bins
  resources :bays
  resources :shelves
  resources :countries
  # Appellations use "Region" language in the UI and routes for buyer-friendly display.
  resources :regions, controller: :regions
  resources :tasting_notes
  resources :wine_clubs do
    get :all, on: :collection
  end
  resources :watch_list_entries do
    get :old_entries, on: :collection
    patch :remove, on: :member
    patch :restore, on: :member
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
