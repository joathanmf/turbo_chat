Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "rooms#new"
  post "salas", to: "rooms#create", as: :rooms
  get "entrar", to: "rooms#enter", as: :enter

  scope "r/:token", constraints: { token: /[A-Za-z0-9_-]{22}/ } do
    get "/", to: "rooms#show", as: :room
    post "nome", to: "users#create", as: :room_user
    post "mensagens", to: "messages#create", as: :room_messages
  end
end
