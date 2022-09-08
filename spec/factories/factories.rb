# frozen_string_literal: true

FactoryBot.define do
  factory :company do
    name { 'Codify' }
    nit { '123' }
    address { 'Anywhere' }
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
  end

  factory :client do
    code { '055' }
    name { 'Juan' }
    nit { '123' }
    email { 'example@example.com' }
    phone { '12345' }
    company factory: :company
  end

  factory :daily_code do
    code { 'ABC' }
    effective_date { '2022-01-01' }
    control_code { '123abc' }
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
    expiration_date { '2022-01-01' }
    branch_office factory: :branch_office

    after(:build) do |cuis_code, evaluator|
      cuis_code.current_number = 1 unless evaluator.default_values
    end
  end

  factory :measurement do
    description { 'ABC' }
  end

  factory :invoice_status do
    description { 'ABC' }
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
    document_sector_code { 1 }
    legend { 'legend' }
    user { 'jperez' }
    branch_office factory: :branch_office
    invoice_status factory: :invoice_status

    after(:build) do |invoice, evaluator|
      unless evaluator.default_values
        invoice.cash_paid = 1
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

  factory :document_type do
    code { '12345' }
    description { 'Abc' }
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

  factory :mail_setting do
    address { 'smtp.example.com' }
    port { '25' }
    domain { 'example.com' }
    user_name { 'example@example.com' }
    password { 'passwords' }
  end

  factory :significative_event do
    code { '12345' }
    description { 'Abc' }
  end

  factory :contingency do
    start_date { '2022-08-30' }
    branch_office factory: :branch_office
    significative_event factory: :significative_event
  end

  factory :point_of_sale do
    name { 'ABC' }
    code { 1 }
    branch_office factory: :branch_office
  end

  factory :cancellation_reason do
    code { '12345' }
    description { 'Abc' }
  end
end
