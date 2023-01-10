# frozen_string_literal: true

FactoryBot.define do
  factory :page_size do
    description { 'Roll' }
  end

  factory :company do
    name { 'Codify' }
    nit { '123' }
    address { 'Anywhere' }
    page_size factory: :page_size
  end

  factory :branch_office do
    name { 'Sucursal 1' }
    number { 1 }
    city { 'Santa Cruz' }
    phone { '123' }
    address { 'abc' }
    company factory: :company
  end

  factory :product do
    primary_code { 'Abc' }
    description { 'Abc' }
    sin_code { '123' }
    company factory: :company
    measurement factory: :measurement
  end

  factory :document_type do
    code { 1 }
    description { 'Abc' }
  end

  factory :customer do
    code { '00001' }
    name { 'Juan' }
    nit { '123' }
    email { 'example@example.com' }
    phone { '12345' }
    company factory: :company
    document_type factory: :document_type
  end

  factory :daily_code do
    code { 'ABC' }
    effective_date { Date.today }
    control_code { '123abc' }
    end_date { DateTime.now + 1.hour }
    point_of_sale { 0 }
    branch_office factory: :branch_office
  end

  factory :delegated_token do
    token { 'ABC' }
    expiration_date { '2022-01-01' }
    company factory: :company
  end

  factory :cuis_code do
    transient do
      default_values { false }
    end
    code { 'ABC' }
    expiration_date { DateTime.now + 1.hour }
    branch_office factory: :branch_office
    point_of_sale { 0 }

    after(:build) do |cuis_code, evaluator|
      cuis_code.current_number = 1 unless evaluator.default_values
    end
  end

  factory :measurement do
    description { 'ABC' }
  end

  factory :invoice_status do
    description { 'Vigente' }
  end

  factory :payment_channel do
    description { 'ABC' }
  end

  factory :invoice do
    transient do
      default_values { false }
    end

    company_nit { '123' }
    company_name { 'SRL' }
    municipality { 'Santa Cruz' }
    phone { '123' }
    address { 'abc' }
    cuf { 'abc' }
    cufd_code { 'abc' }
    date { '2022-01-01' }
    document_type { 1 }
    client_code { '01' }
    payment_method { 1 }
    currency_code { 1 }
    exchange_rate { 1 }
    currency_total { 1 }
    number { 1 }
    subtotal { 1 }
    total { 1 }
    amount_payable { 1 }
    document_sector_code { 1 }
    point_of_sale { 0 }
    legend { 'legend' }
    user { 'jperez' }
    branch_office factory: :branch_office
    invoice_status factory: :invoice_status

    after(:build) do |invoice, evaluator|
      unless evaluator.default_values
        invoice.gift_card_total = 0
        invoice.business_name = 'Codify'
        invoice.business_nit = '123'
      end
    end
  end

  factory :invoice_detail do
    transient do
      default_values { false }
    end

    economic_activity_code { 1 }
    sin_code { 1 }
    product_code { '01' }
    description { 'ABC' }
    unit_price { 1 }
    subtotal { 1 }
    total { 1 }
    product factory: :product
    invoice factory: :invoice
    measurement factory: :measurement

    after(:build) do |invoice_detail, evaluator|
      unless evaluator.default_values
        invoice_detail.quantity = 1
        invoice_detail.discount = 0
      end
    end
  end

  factory :economic_activity do
    code { '12345' }
    description { 'Abc' }
    activity_type { 'A' }
    company factory: :company
  end

  factory :payment_method do
    code { '12345' }
    description { 'Abc' }
  end

  factory :pos_type do
    code { '12345' }
    description { 'Abc' }
  end

  factory :legend do
    code { '12345' }
    description { 'Abc' }
    economic_activity factory: :economic_activity
  end

  factory :company_setting do
    address { 'smtp.example.com' }
    port { '25' }
    domain { 'example.com' }
    user_name { 'example@example.com' }
    password { 'passwords' }
    api_key { '123456' }
    system_code { '2' }
    company factory: :company
  end

  factory :significative_event do
    code { '12345' }
    description { 'Abc' }
  end

  factory :point_of_sale do
    name { 'ABC' }
    branch_office factory: :branch_office
  end

  factory :contingency do
    start_date { '2022-08-30' }
    point_of_sale factory: :point_of_sale
    significative_event factory: :significative_event
  end

  factory :cancellation_reason do
    code { '1' }
    description { 'Abc' }
  end

  factory :document_sector do
    code { '12345' }
    description { 'Abc' }
    economic_activity factory: :economic_activity
  end

  factory :product_code do
    code { '12345' }
    description { 'Abc' }
    economic_activity factory: :economic_activity
  end

  factory :contingency_code do
    transient do
      default_values { false }
    end

    code { '123abc' }
    document_sector_code { 1 }
    limit { 10 }
    economic_activity factory: :economic_activity
    after(:build) do |contingency_code, evaluator|
      unless evaluator.default_values
        contingency_code.current_use = 0
        contingency_code.available = true
      end
    end
  end

  factory :invoice_log do
    code { 123 }
    description { 'Error code.' }
    invoice factory: :invoice
  end

  factory :contingency_log do
    code { 123 }
    description { 'ABC' }
    contingency factory: :contingency
  end

  factory :user do
    full_name { 'Juan Perez' }
    username { 'jperez' }
    role { 2 }
    email { 'jperez@example.com' }
    password { 'abc123.' }
    password_confirmation { 'abc123.' }
  end

  factory :country do
    code { 123 }
    description { 'ABC' }
  end

  factory :currency_type do
    code { 123 }
    description { 'ABC' }
  end

  factory :environment_type do
    description { 'Abc' }
  end

  factory :modality do
    description { 'Abc' }
  end

  factory :document_sector_type do
    code { '123abc' }
    description { 'ABC' }
  end

  factory :invoice_type do
    code { '123abc' }
    description { 'ABC' }
  end

  factory :issuance_type do
    code { '123abc' }
    description { 'ABC' }
  end

  factory :room_type do
    code { '123abc' }
    description { 'ABC' }
  end

  factory :service_message do
    code { '123abc' }
    description { 'ABC' }
  end

  factory :account_type do
    description { 'Activo' }
  end

  factory :account_level do
    description { 'Grupo' }
  end

  factory :cycle do
    year { 2022 }
    status { 'ABIERTA' }
    start_date { '2022-01-01' }
    end_date { '2022-12-31' }
    company factory: :company
  end

  factory :account do
    number { '1.1.1' }
    description { 'Cuenta 1' }
    company factory: :company
    cycle factory: :cycle
    account_type factory: :account_type
    account_level factory: :account_level
  end

  factory :currency do
    description { 'Bolivianos' }
    abbreviation { 'Bs' }
  end

  factory :transaction_type do
    description { 'Ingreso' }
  end

  factory :entry do
    accounting_transaction factory: :accounting_transaction
    account factory: :account
    debit_bs { 0 }
    credit_bs { 0 }
    debit_sus { 0 }
    credit_sus { 0 }
  end

  factory :accounting_transaction do
    date { '01/01/2022' }
    gloss { 'asdf' }
    status { 0 }
    currency factory: :currency
    period factory: :period
    transaction_type factory: :transaction_type
    company factory: :company
  end

  factory :exchange_rate do
    date { '01/01/2022' }
    rate { 1 }
    company factory: :company
  end

  factory :payment do
    mount { 10 }
    invoice factory: :invoice
    payment_method factory: :payment_method
  end

  factory :order do
    number { 9000 }
    date { DateTime.now }
    total { 1 }
    order_id { 10_000 }
    company factory: :company
  end

  factory :order_detail do
    order factory: :order
    product factory: :product
    title { 'Product 01' }
    sku { 'L80000' }
    total { 1 }
    discount { 0 }
    quantity { 1 }
  end

  factory :order_customer do
    order factory: :order
    name { 'Juan Perez' }
    email { 'juan@perez.com' }
    phone { '+59177777777' }
    customer_id { 1 }
  end

  factory :accounting_transaction_log do
    full_name { 'Juan Perez' }
    action { 'UPDATE' }
    log_action { '{\"date\"=>\"2022-12-23\", \"gloss\"=>\"prueba 4\"}' }
    accounting_transaction factory: :accounting_transaction
  end

  factory :brand do
    description { 'ABCabc' }
  end

  factory :product_category do
    description { 'ABCabc' }
  end

  factory :product_status do
    description { 'ABCabc' }
  end

  factory :product_type do
    description { 'ABCabc' }
  end

  factory :tag do
    description { 'ABCabc' }
    association :taggable, factory: :order
  end

  factory :transaction_number do
    period factory: :period
    transaction_type factory: :transaction_type
    number { 1 }
  end

  factory :variant do
    title { 'ABCabc' }
    product factory: :product
  end

  factory :period do
    description { 'Enero - 2023' }
    status { 'ABIERTO' }
    start_date { '01-01-2023' }
    cycle factory: :cycle
  end
end
