Rails.application.routes.draw do
  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }

  with_options format: false do
    get "/routes" => "routes#show"
    put "/routes" => "routes#update"
    delete "/routes" => "routes#destroy"
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
