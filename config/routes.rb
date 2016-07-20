PafsCore::Engine.routes.draw do
  resources :projects do
    collection do
      get :pipeline
      post :funding
    end

    member do
      get :reference_number
      get :download_funding_calculator
      get :delete_funding_calculator
      get :download_benefit_area_file
      get :delete_benefit_area_file
    end
  end
  resources :account_requests

  get 'projects/:id/:step' => 'projects#step', as: :project_step
  patch 'projects/:id/:step' => 'projects#save', as: :save_project_step
end
