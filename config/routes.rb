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
      resources :branch_offices do
        post 'siat/generate_cuis'
        get 'siat/show_cuis'
        post 'siat/generate_cufd'
        get 'siat/show_cufd'
        get 'siat/siat_product_codes'
        post 'siat/load_economic_activities'
        post 'siat/load_document_types'
        post 'siat/load_payment_methods'
        post 'siat/load_legends'
      end
      resources :document_types, only: %i[index]
      resources :legends, only: %i[index]
      resources :payment_methods, only: %i[index]

      # siat controller
      post 'siat/bulk_products_update'
    end
  end
end
