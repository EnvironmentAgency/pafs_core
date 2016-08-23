PafsCore::Engine.routes.draw do
  resources :bootstraps do
    collection do
      post :funding
      get :spreadsheet
    end
  end

  resources :projects do
    collection do
      get :pipeline
    end
    member do
      # get :reference_number
      get :download_funding_calculator
      get :delete_funding_calculator
      get :download_benefit_area_file
      get :delete_benefit_area_file
      get :submit
    end
  end
  resources :account_requests

  get 'bootstrap/:id/:step' => 'bootstraps#step', as: :bootstrap_step
  patch 'bootstrap/:id/:step' => 'bootstraps#save', as: :save_bootstrap_step
  get 'projects/:id/:step' => 'projects#step', as: :project_step
  patch 'projects/:id/:step' => 'projects#save', as: :save_project_step
end
