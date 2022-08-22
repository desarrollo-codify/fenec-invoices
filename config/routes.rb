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
        resources :delegated_tokens, shallow: true
        resources :branch_offices, shallow: true do
          resources :daily_codes, shallow: true
          resources :invoices, shallow: true
          post 'invoices/generate'
        end
        resources :products, shallow: true
        resources :clients, only: %i[index create]
        resources :economic_activities, only: %i[index]
      end
      resources :branch_offices, only: %i[show edit update destroy] do
        resources :daily_codes, shallow: true
        resources :invoices, shallow: true
        post 'siat/generate_cuis'
        get 'siat/show_cuis'
        post 'siat/generate_cufd'
        get 'siat/show_cufd'
        post 'siat/product_codes'
        post 'siat/economic_activities'
        post 'siat/document_types'
        post 'siat/payment_methods'
        post 'siat/legends'
      end
      resources :economic_activities, only: :show do
        resources :legends, only: %i[index]
      end
      resources :document_types, only: %i[index]
      resources :payment_methods, only: %i[index]
      resources :measurement_types, only: %i[index]

      # siat controller
      post 'siat/bulk_products_update'
    end
  end
end
