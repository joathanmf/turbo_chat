Rails.application.routes.draw do
  root "chat#index"

  scope "/chat", as: "chat" do
    get "/", to: "chat#enter"
    post "/", to: "chat#create"

    scope ":room_name" do
      get "/", to: "chat#show", as: :show
      get "users/new", to: "users#new", as: :users_new
      post "users/new", to: "users#create", as: :users_create

      post "create", to: "messages#create", as: :create
    end
  end
end
