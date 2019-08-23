Rails.application.routes.draw do
  root :to => redirect('/mindmaps/new')
  resources :mindmaps
end
