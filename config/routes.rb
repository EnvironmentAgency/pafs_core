PafsCore::Engine.routes.draw do
  resources :projects do
    collection do
      get :pipeline
    end

    member do
      get :reference_number
      get :download_funding_calculator
    end
  end
  resources :account_requests

  get 'projects/:id/:step' => 'projects#step', as: :project_step
  patch 'projects/:id/:step' => 'projects#save', as: :save_project_step
end
