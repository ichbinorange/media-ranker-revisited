Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "works#root"
  
  # Routes for OAuth login and logout
  get "/auth/github", as: "github_login"
  get "/auth/:provider/callback", to: "users#create", as: "omniauth_callback"
  delete "/logout" to: "users#destroy", as: "logout"

  resources :works
  post "/works/:id/upvote", to: "works#upvote", as: "upvote"

  resources :users, only: [:index, :show]
end
