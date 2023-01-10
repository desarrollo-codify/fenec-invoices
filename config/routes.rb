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
      resources :system_modules do
        resources :pages, only: %i[index create]
      end
      resources :pages, only: %i[show update destroy] do
        resources :page_options, only: %i[index create]
      end
      resources :page_options, only: %i[show update destroy]
      resources :email_verifications, only: %i[] do
        get :confirm_email, on: :member
      end
      resources :environment_types, only: %i[index]
      resources :modalities, only: %i[index]
      resources :users, shallow: true do
        post :default_password, on: :member
        put :reset_password, on: :member
      end
      resources :companies do
        resources :accounting_transactions, shallow: true do
          post :cancel, on: :member
        end
        resources :accounts, shallow: true do
          post :import, on: :collection
          get :for_transactions, on: :collection
        end
        resources :cycles, shallow: true do
          get :current, on: :collection
          resources :periods, except: %i[show destroy] do
            post :close, on: :member
            get :current, on: :collection
          end
        end
        resources :delegated_tokens, shallow: true
        resources :exchange_rates, shallow: true do
          get :find_exchange_rate_by_date, on: :collection
        end
        resources :branch_offices, only: %i[index create]
        resources :aromas, only: %i[index]
        post :add_invoice_types, on: :member
        post :add_document_sector_types, on: :member
        post :add_measurements, on: :member
        post :add_payment_methods, on: :member
        post :mail_test, on: :member
        post :remove_invoice_type, on: :member
        post :remove_document_sector_type, on: :member
        post :remove_measurements, on: :member
        post :remove_payment_methods, on: :member
        resources :products, shallow: true do
          post :homologate, on: :collection
          post :import, on: :collection
        end
        resources :customers, shallow: true
        resources :economic_activities, only: %i[index]
        get :logo, on: :member
        get :cuis_codes, on: :member
        get :contingencies, on: :member
        get :invoices, on: :member
        get :product_codes, on: :member
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
        post :verify_status, on: :member
        get :logs, on: :member
      end
      resources :contingency_codes, only: %i[show update destroy]
      resources :aromas, only: %i[destroy]

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

      get 'accounting/currencies'
      get 'accounting/transaction_types'

      post 'aromas/generate'

      resources :product_types
      resources :brands
      resources :account_levels, only: %i[index]
      resources :account_types, only: %i[index]
      resources :orders, only: %i[update]
    end
  end
end
