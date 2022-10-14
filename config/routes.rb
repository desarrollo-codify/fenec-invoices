# frozen_string_literal: true

Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  resources :invoicing, only: :show

  post 'siat_tests/sync_codes'
  post 'siat_tests/cufd_codes'
  post 'siat_tests/generate_invoices'
  post 'siat_tests/cancel_invoices'

  namespace :api do
    namespace :v1 do
      resources :users, shallow: true
      resources :companies do
        resources :delegated_tokens, shallow: true
        resources :branch_offices, only: %i[index create]
        resources :products, shallow: true do
          post :homologate, on: :collection
        end
        resources :clients, only: %i[index create]
        resources :economic_activities, only: %i[index]
        get :logo, on: :member
        put '/settings', to: 'companies#update_settings'
      end
      get '/branch_offices/:branch_office_id/daily_codes/current', to: 'daily_codes#current'
      get '/branch_offices/:branch_office_id/cuis_codes/current', to: 'cuis_codes#current'
      resources :branch_offices, only: %i[show update destroy] do
        get :contingencies, on: :member
        resources :daily_codes, shallow: true
        resources :cuis_codes, only: %i[index]
        resources :invoices, only: %i[index create] do
          get :pending, on: :collection
        end
        resources :point_of_sales, shallow: true do
          resources :contingencies, shallow: true do
            post :close, on: :member
          end
        end
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
        post 'siat/significative_events'
        post 'siat/pos_types'
        post 'siat/countries'
        post 'siat/issuance_types'
        post 'siat/room_types'
        post 'siat/currency_types'
        post 'siat/invoice_types'
        post 'siat/cancellation_reasons'
        post 'siat/document_sectors'
        post 'siat/service_messages'
        post 'siat/document_sector_types'
        get 'siat/verify_nit'
        post 'siat/point_of_sales'
      end

      resources :economic_activities, only: :show do
        resources :legends, only: %i[index]
        resources :document_sectors, only: %i[index]
        resources :product_codes, only: %i[index]
        resources :contingency_codes, only: %i[index create]
      end
      resources :invoices, only: %i[show update destroy] do
        post :cancel, on: :member
        post :resend, on: :member
      end
      resources :contingency_codes, only: %i[show update destroy]
      resources :clients, only: %i[update destroy]

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
      get 'global_settings/measurement_types'
      get 'global_settings/payment_methods'
      get 'global_settings/service_messages'
      get 'global_settings/document_sector_types'
      get 'global_settings/product_codes'
    end
  end
end
