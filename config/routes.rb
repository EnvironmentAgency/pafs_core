PafsCore::Engine.routes.draw do
  resources :projects
  resources :account_requests

  get 'projects/:id/:step' => 'projects#step', as: :project_step
  patch 'projects/:id/:step' => 'projects#save', as: :save_project_step
end
