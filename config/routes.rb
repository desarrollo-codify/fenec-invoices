Rails.application.routes.draw do
  devise_for :users,
    controllers: {
        sessions: 'users/sessions',
        registrations: 'users/registrations'
    }, 
    defaults: { format: :json }

  namespace :api do
    namespace :v1 do
      resources :companies
    end
  end
end
