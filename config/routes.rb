Rails.application.routes.draw do
  with_options format: false do |r|
    r.resources :backends, only: %i[show update destroy]
    
    r.get "/routes" => "routes#show"
    r.put "/routes" => "routes#update"
    r.delete "/routes" => "routes#destroy"
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
