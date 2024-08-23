Rails.application.routes.draw do
  with_options format: false do
    resources :backends, only: %i[show update destroy]

    get "/routes" => "routes#show"
    put "/routes" => "routes#update"
    delete "/routes" => "routes#destroy"
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
