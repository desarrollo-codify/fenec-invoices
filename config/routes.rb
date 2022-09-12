# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users,
             controllers: {
               sessions: 'users/sessions',
               registrations: 'users/registrations'
             },
             defaults: { format: :json }

  resources :invoicing, only: :show

  namespace :api do
    namespace :v1 do
      resources :companies do
        resources :delegated_tokens, shallow: true
        resources :branch_offices, only: %i[index create]
        resources :products, shallow: true do
          post :homologate, on: :collection
        end
        resources :clients, only: %i[index create]
        resources :economic_activities, only: %i[index]
        get :logo, on: :member
      end
      resources :branch_offices, only: %i[show update destroy] do
        resources :daily_codes, shallow: true
        resources :contingencies, shallow: true do
          post :close, on: :member
        end
        resources :invoices, only: %i[index create] do
          get :pending, on: :collection
        end
        resources :point_of_sales, shallow: true
        post 'siat/pruebas'
        post 'siat/generate_cuis'
        get 'siat/show_cuis'
        post 'siat/generate_cufd'
        get 'siat/show_cufd'
        post 'siat/product_codes'
        post 'siat/economic_activities'
        post 'siat/document_types'
        post 'siat/payment_methods'
        post 'siat/legends'
        post 'siat/measurements'
        post 'siat/pos_types'
        post 'siat/countries'
        post 'siat/issuance_types'
        post 'siat/room_types'
        post 'siat/currency_types'
        post 'siat/invoice_types'
      end
      resources :economic_activities, only: :show do
        resources :legends, only: %i[index]
      end
      resources :payment_methods, only: %i[index]
      resources :invoices, only: %i[show update destroy] do
        post :cancel, on: :member
      end

      # siat controller
      post 'siat/bulk_products_update'
      post 'siat/verify_communication'

      get 'global_settings/cancellation_reasons'
      get 'global_settings/significative_events'
      get 'global_settings/countries'
      get 'global_settings/document_types'
      get 'global_settings/issuance_types'
      get 'global_settings/room_types'
      get 'global_settings/currency_types'
      get 'global_settings/pos_types'
      get 'global_settings/invoice_types'
    end
  end
end
