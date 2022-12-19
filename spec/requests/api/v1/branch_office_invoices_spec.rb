# frozen_string_literal: true

require 'rails_helper'
require 'siat_available'
require 'verify_nit'

RSpec.describe '/api/v1/branch_offices/:branch_office_id/invoices', type: :request do
  let(:valid_attributes) do
    {
      invoice: {
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        payment_method: 1,
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 100,
        qr_paid: 0,
        card_paid: 0,
        online_paid: 0,
        voucher_paid: 0
      }
    }
  end

  let(:invalid_attributes) do
    {
      invoice: {
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        payment_method: 1,
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 90,
        qr_paid: 0,
        card_paid: 0,
        online_paid: 0,
        voucher_paid: 0
      }
    }
  end

  # payment_method
  let(:valid_attributes_card_paid) do
    {
      invoice: {
        municipality: 'Santa Cruz',
        card_number: '12344321',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        payment_method: 2,
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 0,
        card_paid: 100,
        online_paid: 0,
        voucher_paid: 0
      }
    }
  end

  let(:invalid_attributes_card_paid) do
    {
      invoice: {
        municipality: 'Santa Cruz',
        card_number: '12344321',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        payment_method: 2,
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 0,
        card_paid: 98,
        online_paid: 0,
        voucher_paid: 0
      }
    }
  end

  let(:valid_attributes_qr_paid) do
    {
      invoice: {
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        payment_method: 7,
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 100,
        card_paid: 0,
        online_paid: 0,
        voucher_paid: 0
      }
    }
  end

  let(:invalid_attributes_qr_paid) do
    {
      invoice: {
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        payment_method: 7,
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 98,
        card_paid: 0,
        online_paid: 0,
        voucher_paid: 0
      }
    }
  end

  let(:valid_attributes_online_paid) do
    {
      invoice: {
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        payment_method: 33,
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 0,
        card_paid: 0,
        online_paid: 100,
        voucher_paid: 0
      }
    }
  end

  let(:invalid_attributes_online_paid) do
    {
      invoice: {
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        payment_method: 33,
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 0,
        card_paid: 0,
        online_paid: 80,
        voucher_paid: 0
      }
    }
  end

  let(:valid_attributes_gift_card_paid) do
    {
      invoice: {
        payment_method: 27,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 100,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 0,
        card_paid: 0,
        online_paid: 0,
        voucher_paid: 0
      }
    }
  end

  let(:invalid_attributes_gift_card_paid) do
    {
      invoice: {
        payment_method: 27,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 99,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 0,
        card_paid: 0,
        online_paid: 0,
        voucher_paid: 0
      }
    }
  end

  let(:valid_attributes_cash_and_card_paid) do
    {
      invoice: {
        payment_method: 10,
        card_number: '12344321',
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 50,
        qr_paid: 0,
        card_paid: 50,
        online_paid: 0,
        voucher_paid: 0
      }
    }
  end

  let(:invalid_attributes_cash_and_card_paid) do
    {
      invoice: {
        payment_method: 10,
        card_number: nil,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 50,
        qr_paid: 0,
        card_paid: 50,
        online_paid: 0,
        voucher_paid: 0
      }
    }
  end

  let(:valid_attributes_card_and_qr_paid) do
    {
      invoice: {
        payment_method: 18,
        card_number: '12344321',
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 50,
        card_paid: 50,
        online_paid: 0,
        voucher_paid: 0
      }
    }
  end

  let(:invalid_attributes_card_and_qr_paid) do
    {
      invoice: {
        payment_method: 18,
        card_number: nil,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 50,
        card_paid: 50,
        online_paid: 0,
        voucher_paid: 0
      }
    }
  end

  let(:valid_attributes_card_and_gift_card_paid) do
    {
      invoice: {
        payment_method: 40,
        card_number: '12344321',
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 50,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 0,
        card_paid: 50,
        online_paid: 0,
        voucher_paid: 0
      }
    }
  end

  let(:invalid_attributes_card_and_gift_card_paid) do
    {
      invoice: {
        payment_method: 40,
        card_number: nil,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 50,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 0,
        card_paid: 50,
        online_paid: 0,
        voucher_paid: 0
      }
    }
  end

  let(:valid_attributes_card_and_online_paid) do
    {
      invoice: {
        payment_method: 43,
        card_number: '12344321',
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 0,
        card_paid: 50,
        online_paid: 50,
        voucher_paid: 0
      }
    }
  end

  let(:invalid_attributes_card_and_online_paid) do
    {
      invoice: {
        payment_method: 43,
        card_number: nil,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 0,
        card_paid: 50,
        online_paid: 50,
        voucher_paid: 0
      }
    }
  end

  let(:valid_attributes_qr_and_cash_paid) do
    {
      invoice: {
        payment_method: 13,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 50,
        qr_paid: 50,
        card_paid: 0,
        online_paid: 0,
        voucher_paid: 0
      }
    }
  end

  let(:invalid_attributes_qr_and_cash_paid) do
    {
      invoice: {
        payment_method: 13,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 49,
        qr_paid: 50,
        card_paid: 0,
        online_paid: 0,
        voucher_paid: 0
      }
    }
  end

  let(:valid_attributes_qr_and_gift_card_paid) do
    {
      invoice: {
        payment_method: 64,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 50,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 50,
        card_paid: 0,
        online_paid: 0,
        voucher_paid: 0
      }
    }
  end

  let(:invalid_attributes_qr_and_gift_card_paid) do
    {
      invoice: {
        payment_method: 64,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 50,
        card_paid: 0,
        online_paid: 0,
        voucher_paid: 0
      }
    }
  end

  let(:valid_attributes_qr_and_online_paid) do
    {
      invoice: {
        payment_method: 67,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 50,
        card_paid: 0,
        online_paid: 50,
        voucher_paid: 0
      }
    }
  end

  let(:invalid_attributes_qr_and_online_paid) do
    {
      invoice: {
        payment_method: 67,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 50,
        card_paid: 0,
        online_paid: 0,
        voucher_paid: 0
      }
    }
  end

  let(:valid_attributes_online_and_cash_paid) do
    {
      invoice: {
        payment_method: 38,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 50,
        qr_paid: 0,
        card_paid: 0,
        online_paid: 50,
        voucher_paid: 0
      }
    }
  end

  let(:invalid_attributes_online_and_cash_paid) do
    {
      invoice: {
        payment_method: 38,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 80,
        qr_paid: 0,
        card_paid: 0,
        online_paid: 50,
        voucher_paid: 0
      }
    }
  end

  let(:valid_attributes_online_and_gift_card_paid) do
    {
      invoice: {
        payment_method: 78,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 50,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 0,
        card_paid: 0,
        online_paid: 50,
        voucher_paid: 0
      }
    }
  end

  let(:invalid_attributes_online_and_gift_card_paid) do
    {
      invoice: {
        payment_method: 78,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 50,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 0,
        card_paid: 0,
        online_paid: 60,
        voucher_paid: 0
      }
    }
  end

  let(:valid_attributes_gift_card_and_cash_paid) do
    {
      invoice: {
        payment_method: 35,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 50,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 50,
        qr_paid: 0,
        card_paid: 0,
        online_paid: 0,
        voucher_paid: 0
      }
    }
  end

  let(:invalid_attributes_gift_card_and_cash_paid) do
    {
      invoice: {
        payment_method: 35,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 50,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 100,
        qr_paid: 0,
        card_paid: 0,
        online_paid: 0,
        voucher_paid: 0
      }
    }
  end

  let(:valid_attributes_voucher_paid) do
    {
      invoice: {
        payment_method: 4,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 0,
        card_paid: 0,
        online_paid: 0,
        voucher_paid: 100
      }
    }
  end

  let(:invalid_attributes_voucher_paid) do
    {
      invoice: {
        payment_method: 4,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 0,
        card_paid: 0,
        online_paid: 0,
        voucher_paid: 50
      }
    }
  end

  let(:valid_attributes_voucher_and_cash_paid) do
    {
      invoice: {
        payment_method: 12,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 50,
        qr_paid: 0,
        card_paid: 0,
        online_paid: 0,
        voucher_paid: 50
      }
    }
  end

  let(:invalid_attributes_voucher_and_cash_paid) do
    {
      invoice: {
        payment_method: 12,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 100,
        qr_paid: 0,
        card_paid: 0,
        online_paid: 0,
        voucher_paid: 50
      }
    }
  end

  let(:valid_attributes_voucher_and_card_paid) do
    {
      invoice: {
        payment_method: 17,
        card_number: '12344321',
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 0,
        card_paid: 50,
        online_paid: 0,
        voucher_paid: 50
      }
    }
  end

  let(:invalid_attributes_voucher_and_card_paid) do
    {
      invoice: {
        payment_method: 17,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 0,
        card_paid: 50,
        online_paid: 0,
        voucher_paid: 50
      }
    }
  end

  let(:valid_attributes_voucher_and_qr_paid) do
    {
      invoice: {
        payment_method: 21,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 50,
        card_paid: 0,
        online_paid: 0,
        voucher_paid: 50
      }
    }
  end

  let(:invalid_attributes_voucher_and_qr_paid) do
    {
      invoice: {
        payment_method: 21,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 100,
        card_paid: 0,
        online_paid: 0,
        voucher_paid: 50
      }
    }
  end

  let(:valid_attributes_voucher_and_gift_card_paid) do
    {
      invoice: {
        payment_method: 53,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 50,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 0,
        card_paid: 0,
        online_paid: 0,
        voucher_paid: 50
      }
    }
  end

  let(:invalid_attributes_voucher_and_gift_card_paid) do
    {
      invoice: {
        payment_method: 53,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 50,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 0,
        card_paid: 0,
        online_paid: 0,
        voucher_paid: 100
      }
    }
  end

  let(:valid_attributes_voucher_and_online_paid) do
    {
      invoice: {
        payment_method: 56,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 0,
        card_paid: 0,
        online_paid: 50,
        voucher_paid: 50
      }
    }
  end

  let(:invalid_attributes_voucher_and_online_paid) do
    {
      invoice: {
        payment_method: 56,
        municipality: 'Santa Cruz',
        phone: '12345',
        address: 'por ahi',
        date: '2022-01-01',
        total: 100,
        company_name: 'Codify',
        company_nit: '12345',
        business_name: 'Juan Perez',
        business_nit: '1234567',
        client_code: '00001',
        subtotal: 100,
        gift_card_total: 0,
        discount: 0,
        currency_code: 1,
        exchange_rate: 1,
        currency_total: 100,
        user: 'jperez',
        point_of_sale: 0,
        invoice_details_attributes: [
          {
            economic_activity_code: 12_345,
            product_code: 'Abc',
            description: 'Algo bonito',
            quantity: 1,
            measurement_id: 1,
            unit_price: 100,
            discount: 0,
            subtotal: 100
          }
        ]
      },
      payment: {
        cash_paid: 0,
        qr_paid: 0,
        card_paid: 0,
        online_paid: 100,
        voucher_paid: 50
      }
    }
  end

  let(:invoice_types) do
    {
      invoice_type_ids: [1]
    }
  end

  let(:document_sector_types) do
    {
      document_sector_type_ids: [1]
    }
  end

  let(:measurements) do
    {
      measurements_ids: [1]
    }
  end

  let(:valid_headers) do
    {}
  end

  describe 'GET /index' do
    let(:branch_office) { create(:branch_office) }

    before { create(:payment_method) }
    let(:invoice) { build(:invoice, branch_office: branch_office) }

    before(:each) do
      invoice.payments.build(mount: 1, payment_method_id: 1)
      invoice.save
    end

    it 'renders a successful response' do
      get api_v1_branch_office_invoices_url(branch_office_id: branch_office.id), headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    before { create(:invoice_type) }
    before { create(:document_sector_type) }
    before { create(:environment_type) }
    before { create(:modality) }
    before { create(:company, environment_type_id: 1, modality_id: 1) }

    before(:each) do
      create(:payment_method, code: 1)
      create(:payment_method, code: 2)
      create(:payment_method, code: 4)
      create(:payment_method, code: 7)
      create(:payment_method, code: 33)
      @company = Company.first
      post add_invoice_types_api_v1_company_url(@company), params: invoice_types, as: :json
      post add_document_sector_types_api_v1_company_url(@company), params: document_sector_types, as: :json
    end

    let(:branch_office) { create(:branch_office, company: @company) }

    context 'with valid parameters' do
      before { create(:cuis_code, branch_office: branch_office) }
      before { create(:daily_code, branch_office: branch_office) }
      let(:economic_activity) { create(:economic_activity, company: branch_office.company) }
      before { create(:legend, economic_activity: economic_activity) }
      before { create(:measurement) }
      before { create(:product, company: branch_office.company) }
      before { create(:invoice_status) }
      before { create(:client, company: branch_office.company) }

      it 'creates a new Invoice' do
        expect do
          post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
               params: valid_attributes, headers: valid_headers, as: :json
        end.to change(Invoice, :count).by(1)
      end

      it 'renders a JSON response with the new api_v1_branch_office' do
        post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
             params: valid_attributes, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      before { create(:cuis_code, branch_office: branch_office) }
      before { create(:daily_code, branch_office: branch_office) }
      before { create(:product, company: branch_office.company) }
      let(:economic_activity) { create(:economic_activity, company: branch_office.company) }
      before { create(:legend, economic_activity: economic_activity) }
      before { create(:client, company: branch_office.company) }

      it 'does not create a new Invoice' do
        expect do
          post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
               params: invalid_attributes, as: :json
        end.to change(Invoice, :count).by(0)
      end

      it 'renders a JSON response with errors for the new api_v1_company_branch_office' do
        post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
             params: invalid_attributes, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'when siat is not available' do
      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(false)
        allow(VerifyNit).to receive(:verify).with('123456', branch_office).and_return(true)
      end
      before { create(:cuis_code, branch_office: branch_office) }
      before { create(:daily_code, branch_office: branch_office) }
      before { create(:product, company: branch_office.company) }
      let(:economic_activity) { create(:economic_activity, company: branch_office.company) }
      before { create(:legend, economic_activity: economic_activity) }
      before { create(:document_type, code: 2) }
      before { create(:document_type, code: 3) }
      before { create(:document_type, code: 4) }
      let(:document_type) { create(:document_type, code: 5) }
      before { create(:client, company: branch_office.company, document_type: document_type) }
      before { create(:invoice_status, description: 'Vigente') }
      before { create(:invoice_status, description: 'Anulada') }
      before { create(:measurement) }
      before { create(:company_setting, company: branch_office.company) }

      it 'works' do
        post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
             params: valid_attributes, headers: valid_headers, as: :json
        expect(Invoice.first.exception_code).to eq(1)
      end
    end

    context 'when siat is available' do
      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
      end

      before { create(:cuis_code, branch_office: branch_office) }
      before { create(:daily_code, branch_office: branch_office) }
      before { create(:product, company: branch_office.company) }
      let(:economic_activity) { create(:economic_activity, company: branch_office.company) }
      before { create(:legend, economic_activity: economic_activity) }
      before { create(:document_type, code: 2) }
      before { create(:document_type, code: 3) }
      before { create(:document_type, code: 4) }
      let(:document_type) { create(:document_type, code: 5) }
      before { create(:client, company: branch_office.company, document_type: document_type, nit: '123') }
      before { create(:invoice_status, description: 'Vigente') }
      before { create(:invoice_status, description: 'Anulada') }
      before { create(:measurement) }
      before { create(:company_setting, company: branch_office.company) }

      context 'nit is invalid' do
        before(:each) do
          allow(VerifyNit).to receive(:verify).with('123', branch_office).and_return(false)
        end

        it 'works' do
          post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
               params: valid_attributes, headers: valid_headers, as: :json
          expect(Invoice.first.exception_code).to eq(1)
        end
      end

      context 'nit is valid' do
        before(:each) do
          allow(VerifyNit).to receive(:verify).with('123', branch_office).and_return(true)
        end

        it 'works' do
          post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
               params: valid_attributes, headers: valid_headers, as: :json
          expect(Invoice.first.exception_code).to be_nil
        end
      end
    end

    context 'when method paid is card paid' do
      before { create(:cuis_code, branch_office: branch_office) }
      before { create(:daily_code, branch_office: branch_office) }
      let(:economic_activity) { create(:economic_activity, company: branch_office.company) }
      before { create(:legend, economic_activity: economic_activity) }
      before { create(:measurement) }
      before { create(:product, company: branch_office.company) }
      before { create(:invoice_status) }
      before { create(:client, company: branch_office.company) }

      it 'create new Invoice' do
        expect do
          post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
               params: valid_attributes_card_paid, as: :json
        end.to change(Invoice, :count).by(1)
      end

      it 'does not create a new Invoice' do
        expect do
          post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
               params: invalid_attributes_card_paid, as: :json
        end.to change(Invoice, :count).by(0)
      end

      context 'card and cash paid' do
        it 'create new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: valid_attributes_cash_and_card_paid, as: :json
          end.to change(Invoice, :count).by(1)
        end

        it 'does not create a new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: invalid_attributes_cash_and_card_paid, as: :json
          end.to change(Invoice, :count).by(0)
        end
      end

      context 'card and qr paid' do
        it 'create new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: valid_attributes_card_and_qr_paid, as: :json
          end.to change(Invoice, :count).by(1)
        end

        it 'does not create a new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: invalid_attributes_card_and_qr_paid, as: :json
          end.to change(Invoice, :count).by(0)
        end
      end

      context 'card and gift card paid' do
        it 'create new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: valid_attributes_card_and_gift_card_paid, as: :json
          end.to change(Invoice, :count).by(1)
        end

        it 'does not create a new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: invalid_attributes_card_and_gift_card_paid, as: :json
          end.to change(Invoice, :count).by(0)
        end
      end

      context 'card and online paid' do
        it 'create new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: valid_attributes_card_and_online_paid, as: :json
          end.to change(Invoice, :count).by(1)
        end

        it 'does not create a new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: invalid_attributes_card_and_online_paid, as: :json
          end.to change(Invoice, :count).by(0)
        end
      end
    end

    context 'when method paid is qr paid' do
      before { create(:cuis_code, branch_office: branch_office) }
      before { create(:daily_code, branch_office: branch_office) }
      let(:economic_activity) { create(:economic_activity, company: branch_office.company) }
      before { create(:legend, economic_activity: economic_activity) }
      before { create(:measurement) }
      before { create(:product, company: branch_office.company) }
      before { create(:invoice_status) }
      before { create(:client, company: branch_office.company) }

      it 'create new Invoice' do
        expect do
          post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
               params: valid_attributes_qr_paid, as: :json
        end.to change(Invoice, :count).by(1)
      end

      it 'does not create a new Invoice' do
        expect do
          post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
               params: invalid_attributes_qr_paid, as: :json
        end.to change(Invoice, :count).by(0)
      end

      context 'qr and cash paid' do
        it 'create new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: valid_attributes_qr_and_cash_paid, as: :json
          end.to change(Invoice, :count).by(1)
        end

        it 'does not create a new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: invalid_attributes_qr_and_cash_paid, as: :json
          end.to change(Invoice, :count).by(0)
        end
      end

      context 'qr and gift card paid' do
        it 'create new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: valid_attributes_qr_and_gift_card_paid, as: :json
          end.to change(Invoice, :count).by(1)
        end

        it 'does not create a new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: invalid_attributes_qr_and_gift_card_paid, as: :json
          end.to change(Invoice, :count).by(0)
        end
      end

      context 'qr and online paid' do
        it 'create new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: valid_attributes_qr_and_online_paid, as: :json
          end.to change(Invoice, :count).by(1)
        end

        it 'does not create a new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: invalid_attributes_qr_and_online_paid, as: :json
          end.to change(Invoice, :count).by(0)
        end
      end
    end

    context 'when method paid is online paid' do
      before { create(:cuis_code, branch_office: branch_office) }
      before { create(:daily_code, branch_office: branch_office) }
      let(:economic_activity) { create(:economic_activity, company: branch_office.company) }
      before { create(:legend, economic_activity: economic_activity) }
      before { create(:measurement) }
      before { create(:product, company: branch_office.company) }
      before { create(:invoice_status) }
      before { create(:client, company: branch_office.company) }

      it 'create new Invoice' do
        expect do
          post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
               params: valid_attributes_online_paid, as: :json
        end.to change(Invoice, :count).by(1)
      end

      it 'does not create a new Invoice' do
        expect do
          post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
               params: invalid_attributes_online_paid, as: :json
        end.to change(Invoice, :count).by(0)
      end

      context 'online and cash paid' do
        it 'create new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: valid_attributes_online_and_cash_paid, as: :json
          end.to change(Invoice, :count).by(1)
        end

        it 'does not create a new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: invalid_attributes_online_and_cash_paid, as: :json
          end.to change(Invoice, :count).by(0)
        end
      end

      context 'online and cash paid' do
        it 'create new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: valid_attributes_online_and_cash_paid, as: :json
          end.to change(Invoice, :count).by(1)
        end

        it 'does not create a new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: invalid_attributes_online_and_cash_paid, as: :json
          end.to change(Invoice, :count).by(0)
        end
      end
    end

    context 'when method paid is gift card paid' do
      before { create(:cuis_code, branch_office: branch_office) }
      before { create(:daily_code, branch_office: branch_office) }
      let(:economic_activity) { create(:economic_activity, company: branch_office.company) }
      before { create(:legend, economic_activity: economic_activity) }
      before { create(:measurement) }
      before { create(:product, company: branch_office.company) }
      before { create(:invoice_status) }
      before { create(:client, company: branch_office.company) }

      it 'create new Invoice' do
        expect do
          post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
               params: valid_attributes_gift_card_paid, as: :json
        end.to change(Invoice, :count).by(1)
      end

      it 'does not create a new Invoice' do
        expect do
          post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
               params: invalid_attributes_gift_card_paid, as: :json
        end.to change(Invoice, :count).by(0)
      end

      context 'gift card and cash paid' do
        it 'create new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: valid_attributes_gift_card_and_cash_paid, as: :json
          end.to change(Invoice, :count).by(1)
        end

        it 'does not create a new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: invalid_attributes_gift_card_and_cash_paid, as: :json
          end.to change(Invoice, :count).by(0)
        end
      end
    end

    context 'when method paid is voucher paid' do
      before { create(:cuis_code, branch_office: branch_office) }
      before { create(:daily_code, branch_office: branch_office) }
      let(:economic_activity) { create(:economic_activity, company: branch_office.company) }
      before { create(:legend, economic_activity: economic_activity) }
      before { create(:measurement) }
      before { create(:product, company: branch_office.company) }
      before { create(:invoice_status) }
      before { create(:client, company: branch_office.company) }

      it 'create new Invoice' do
        expect do
          post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
               params: valid_attributes_voucher_paid, as: :json
        end.to change(Invoice, :count).by(1)
      end

      it 'does not create a new Invoice' do
        expect do
          post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
               params: invalid_attributes_voucher_paid, as: :json
        end.to change(Invoice, :count).by(0)
      end

      context 'voucher and cash paid' do
        it 'create new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: valid_attributes_voucher_and_cash_paid, as: :json
          end.to change(Invoice, :count).by(1)
        end

        it 'does not create a new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: invalid_attributes_voucher_and_cash_paid, as: :json
          end.to change(Invoice, :count).by(0)
        end
      end

      context 'voucher and card paid' do
        it 'create new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: valid_attributes_voucher_and_card_paid, as: :json
          end.to change(Invoice, :count).by(1)
        end

        it 'does not create a new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: invalid_attributes_voucher_and_card_paid, as: :json
          end.to change(Invoice, :count).by(0)
        end
      end

      context 'voucher and qr paid' do
        it 'create new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: valid_attributes_voucher_and_qr_paid, as: :json
          end.to change(Invoice, :count).by(1)
        end

        it 'does not create a new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: invalid_attributes_voucher_and_qr_paid, as: :json
          end.to change(Invoice, :count).by(0)
        end
      end

      context 'voucher and gift card paid' do
        it 'create new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: valid_attributes_voucher_and_gift_card_paid, as: :json
          end.to change(Invoice, :count).by(1)
        end

        it 'does not create a new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: invalid_attributes_voucher_and_gift_card_paid, as: :json
          end.to change(Invoice, :count).by(0)
        end
      end

      context 'voucher and online paid' do
        it 'create new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: valid_attributes_voucher_and_online_paid, as: :json
          end.to change(Invoice, :count).by(1)
        end

        it 'does not create a new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: invalid_attributes_voucher_and_online_paid, as: :json
          end.to change(Invoice, :count).by(0)
        end
      end
    end
  end

  describe 'GET /pending' do
    context 'renders a successful response' do
      let(:branch_office) { create(:branch_office) }
      let(:invoice_pending) { build(:invoice, branch_office: branch_office) }
      let(:invoice_not_pending) { build(:invoice, branch_office: branch_office, number: 4, sent_at: '2022-10-10') }
      before { create(:payment_method) }

      it 'renders a successful response' do
        invoice_pending.payments.build(mount: 1, payment_method_id: 1)
        invoice_not_pending.payments.build(mount: 1, payment_method_id: 1)
        invoice_pending.save
        invoice_not_pending.save
        get pending_api_v1_branch_office_invoices_url(branch_office_id: branch_office.id), headers: valid_headers, as: :json
        expect(response).to be_successful
        expect(Invoice.for_sending.count).to eq(1)
      end
    end
  end
end
