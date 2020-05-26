Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :containers 
  get 'portcast_container', to: "containers#portcast"
  get 'portcast_container_detail(/:id)', to: "containers#portcast_container"

end
