Rails.application.routes.draw do
  devise_for :users,
    controllers: {
        sessions: 'users/sessions',
        registrations: 'users/registrations'
    }, 
    defaults: { format: :json }

  namespace :api do
    namespace :v1 do
      resources :companies do 
        resources :branch_offices, shallow: true do
          resources :daily_codes, shallow: true
        end
      end
    end
  end
end
