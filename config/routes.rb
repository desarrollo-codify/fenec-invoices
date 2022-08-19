# frozen_string_literal: true

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
          resources :invoices, shallow: true
        end
        resources :products, shallow: true
        resources :clients, only: %i[index create]
        resources :economic_activities, only: %i[index]
      end
      resources :branch_offices do
        post 'siat/generate_cuis'
        get 'siat/show_cuis'
        post 'siat/generate_cufd'
        get 'siat/show_cufd'
        get 'siat/siat_product_codes'
      end

      # siat controller
      post 'siat/bulk_products_update'
    end
  end
end
