PafsCore::Engine.routes.draw do
  resources :bootstraps do
    collection do
      post :funding
      get :spreadsheet
    end
  end

  namespace :projects do
    resources :downloads, only: :index
  end

  resources :projects do
    collection do
      get :pipeline
    end
    member do
      resources :downloads, only: :index do
        collection do
          get :proposal
          get :benefit_area
          get :funding_calculator
          get :moderation
          get :delete_funding_calculator
          get :delete_benefit_area
        end
      end
      get :submit
      get :complete
      get :unlock
      get :confirm
    end
  end

  resources :multi_downloads, only: :index do
    collection do
      get :generate
      get :proposals
      get :benefit_areas
      get :moderations
    end
  end

  resources :areas, only: [:index, :show] do
    member do
      get :set_user
    end
  end

  get 'bootstrap/:id/:step' => 'bootstraps#step', as: :bootstrap_step
  patch 'bootstrap/:id/:step' => 'bootstraps#save', as: :save_bootstrap_step
  get 'projects/:id/:step' => 'projects#step', as: :project_step
  patch 'projects/:id/:step' => 'projects#save', as: :save_project_step

  post "confirmation" => "confirmation#receipt", as: :confirm_receipt
  match '(errors)/:status', to: 'errors#show', via: :all, constraints: { status: /\d{3}/ }
end
