# frozen_string_literal: true

require 'rails_helper'
require 'siat_available'
require 'verify_nit'

RSpec.describe '/api/v1/branch_offices/:branch_office_id/invoices', type: :request do
  let(:valid_attributes) do
    {
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
      business_nit: '1234567',
      client_code: '00001',
      payment_method: 1,
      subtotal: 100,
      gift_card_total: 0,
      discount: 0,
      currency_code: 1,
      exchange_rate: 1,
      currency_total: 100,
      cash_paid: 100,
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
    }
  end

  let(:invalid_attributes) do
    {
      municipality: nil,
      phone: nil,
      number: nil,
      address: nil,
      date: nil,

      company_name: nil,
      company_nit: nil,

      business_name: nil,
      document_type: nil,
      business_nit: nil,
      client_code: '00001',
      payment_method: nil,
      gift_card_total: -1,
      discount: -1,
      advance: -1,
      currency_code: nil,
      exchange_rate: nil,
      currency_total: nil,
      user: nil,
      subtotal: -1,
      total: -1,
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
    }
  end

  # payment_method
  let(:valid_attributes_card_paid) do
    {
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
      business_nit: '1234567',
      client_code: '00001',
      card_number: '12344321',
      payment_method: 2,
      subtotal: 100,
      gift_card_total: 0,
      discount: 0,
      currency_code: 1,
      exchange_rate: 1,
      currency_total: 100,
      cash_paid: 0,
      card_paid: 100,
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
    }
  end

  let(:invalid_attributes_card_paid) do
    {
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
      business_nit: '1234567',
      client_code: '00001',
      card_number: nil,
      payment_method: 2,
      subtotal: 100,
      gift_card_total: 0,
      discount: 0,
      currency_code: 1,
      exchange_rate: 1,
      currency_total: 100,
      cash_paid: 100,
      card_paid: 0,
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
    }
  end

  let(:valid_attributes_qr_paid) do
    {
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
      business_nit: '1234567',
      client_code: '00001',
      payment_method: 7,
      subtotal: 100,
      gift_card_total: 0,
      discount: 0,
      currency_code: 1,
      exchange_rate: 1,
      currency_total: 100,
      cash_paid: 0,
      qr_paid: 100,
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
    }
  end

  let(:invalid_attributes_qr_paid) do
    {
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
      business_nit: '1234567',
      client_code: '00001',
      payment_method: 7,
      subtotal: 100,
      gift_card_total: 0,
      discount: 0,
      currency_code: 1,
      exchange_rate: 1,
      currency_total: 100,
      cash_paid: 100,
      qr_paid: 0,
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
    }
  end

  let(:valid_attributes_online_paid) do
    {
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
      business_nit: '1234567',
      client_code: '00001',
      payment_method: 33,
      subtotal: 100,
      gift_card_total: 0,
      discount: 0,
      currency_code: 1,
      exchange_rate: 1,
      currency_total: 100,
      cash_paid: 0,
      online_paid: 100,
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
    }
  end

  let(:invalid_attributes_online_paid) do
    {
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
      business_nit: '1234567',
      client_code: '00001',
      payment_method: 33,
      subtotal: 100,
      gift_card_total: 0,
      discount: 0,
      currency_code: 1,
      exchange_rate: 1,
      currency_total: 100,
      cash_paid: 100,
      online_paid: 0,
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
    }
  end

  let(:valid_attributes_gift_card_paid) do
    {
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
      business_nit: '1234567',
      client_code: '00001',
      payment_method: 27,
      subtotal: 100,
      gift_card_total: 100,
      discount: 0,
      currency_code: 1,
      exchange_rate: 1,
      currency_total: 100,
      cash_paid: 0,
      online_paid: 0,
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
    }
  end

  let(:invalid_attributes_gift_card_paid) do
    {
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
      business_nit: '1234567',
      client_code: '00001',
      payment_method: 27,
      subtotal: 100,
      gift_card_total: 0,
      discount: 0,
      currency_code: 1,
      exchange_rate: 1,
      currency_total: 100,
      cash_paid: 100,
      online_paid: 0,
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
    }
  end

  let(:valid_attributes_cash_and_card_paid) do
    {
      payment_method: 10,
      cash_paid: 50,
      card_paid: 50,
      card_number: '12344321',
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
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
    }
  end

  let(:invalid_attributes_cash_and_card_paid) do
    {
      payment_method: 10,
      cash_paid: 100,
      card_paid: 0,
      card_number: nil,
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
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
    }
  end

  let(:valid_attributes_card_and_qr_paid) do
    {
      payment_method: 18,
      qr_paid: 50,
      card_paid: 50,
      card_number: '12344321',
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
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
    }
  end

  let(:invalid_attributes_card_and_qr_paid) do
    {
      payment_method: 18,
      qr_paid: 100,
      card_paid: 0,
      card_number: nil,
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
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
    }
  end

  let(:valid_attributes_card_and_gift_card_paid) do
    {
      payment_method: 40,
      card_paid: 50,
      gift_card_total: 50,
      card_number: '12344321',
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
      business_nit: '1234567',
      client_code: '00001',
      subtotal: 100,
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
    }
  end

  let(:invalid_attributes_card_and_gift_card_paid) do
    {
      payment_method: 40,
      card_paid: 0,
      card_number: nil,
      gift_card_total: 100,
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
      business_nit: '1234567',
      client_code: '00001',
      subtotal: 100,
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
    }
  end

  let(:valid_attributes_card_and_online_paid) do
    {
      payment_method: 43,
      card_paid: 50,
      gift_card_total: 0,
      online_paid: 50,
      card_number: '12344321',
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
      business_nit: '1234567',
      client_code: '00001',
      subtotal: 100,
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
    }
  end

  let(:invalid_attributes_card_and_online_paid) do
    {
      payment_method: 43,
      card_paid: 0,
      card_number: nil,
      online_paid: 100,
      gift_card_total: 0,
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
      business_nit: '1234567',
      client_code: '00001',
      subtotal: 100,
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
    }
  end

  let(:valid_attributes_qr_and_cash_paid) do
    {
      payment_method: 13,
      qr_paid: 50,
      cash_paid: 50,
      gift_card_total: 0,
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
      business_nit: '1234567',
      client_code: '00001',
      subtotal: 100,
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
    }
  end

  let(:invalid_attributes_qr_and_cash_paid) do
    {
      payment_method: 13,
      qr_paid: 0,
      cash_paid: 100,
      gift_card_total: 0,
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
      business_nit: '1234567',
      client_code: '00001',
      subtotal: 100,
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
    }
  end

  let(:valid_attributes_qr_and_gift_card_paid) do
    {
      payment_method: 64,
      qr_paid: 50,
      cash_paid: 0,
      gift_card_total: 50,
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
      business_nit: '1234567',
      client_code: '00001',
      subtotal: 100,
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
    }
  end

  let(:invalid_attributes_qr_and_gift_card_paid) do
    {
      payment_method: 64,
      qr_paid: 0,
      cash_paid: 0,
      gift_card_total: 100,
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
      business_nit: '1234567',
      client_code: '00001',
      subtotal: 100,
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
    }
  end

  let(:valid_attributes_qr_and_online_paid) do
    {
      payment_method: 67,
      qr_paid: 50,
      online_paid: 50,
      gift_card_total: 0,
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
      business_nit: '1234567',
      client_code: '00001',
      subtotal: 100,
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
    }
  end

  let(:invalid_attributes_qr_and_online_paid) do
    {
      payment_method: 67,
      qr_paid: 0,
      online_paid: 100,
      gift_card_total: 0,
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
      business_nit: '1234567',
      client_code: '00001',
      subtotal: 100,
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
    }
  end

  let(:valid_attributes_online_and_cash_paid) do
    {
      payment_method: 38,
      cash_paid: 50,
      online_paid: 50,
      gift_card_total: 0,
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
      business_nit: '1234567',
      client_code: '00001',
      subtotal: 100,
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
    }
  end

  let(:invalid_attributes_online_and_cash_paid) do
    {
      payment_method: 38,
      cash_paid: 100,
      online_paid: 0,
      gift_card_total: 0,
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
      business_nit: '1234567',
      client_code: '00001',
      subtotal: 100,
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
    }
  end

  let(:valid_attributes_online_and_gift_card_paid) do
    {
      payment_method: 78,
      cash_paid: 0,
      online_paid: 50,
      gift_card_total: 50,
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
      business_nit: '1234567',
      client_code: '00001',
      subtotal: 100,
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
    }
  end

  let(:invalid_attributes_online_and_gift_card_paid) do
    {
      payment_method: 78,
      cash_paid: 0,
      online_paid: 0,
      gift_card_total: 100,
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
      business_nit: '1234567',
      client_code: '00001',
      subtotal: 100,
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
    }
  end

  let(:valid_attributes_gift_card_and_cash_paid) do
    {
      payment_method: 35,
      cash_paid: 50,
      online_paid: 0,
      gift_card_total: 50,
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
      business_nit: '1234567',
      client_code: '00001',
      subtotal: 100,
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
    }
  end

  let(:invalid_attributes_gift_card_and_cash_paid) do
    {
      payment_method: 35,
      cash_paid: 100,
      online_paid: 0,
      gift_card_total: 0,
      municipality: 'Santa Cruz',
      phone: '12345',
      address: 'por ahi',
      date: '2022-01-01',
      total: 100,
      company_name: 'Codify',
      company_nit: '12345',
      business_name: 'Juan Perez',
      document_type: 1,
      business_nit: '1234567',
      client_code: '00001',
      subtotal: 100,
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
    }
  end

  let(:valid_headers) do
    {}
  end

  describe 'GET /index' do
    let(:branch_office) { create(:branch_office) }

    it 'renders a successful response' do
      create(:invoice, branch_office: branch_office)
      get api_v1_branch_office_invoices_url(branch_office_id: branch_office.id), headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    let(:branch_office) { create(:branch_office) }

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
               params: { invoice: valid_attributes }, headers: valid_headers, as: :json
        end.to change(Invoice, :count).by(1)
      end

      it 'renders a JSON response with the new api_v1_branch_office' do
        post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
             params: { invoice: valid_attributes }, headers: valid_headers, as: :json
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
               params: { invoice: invalid_attributes }, as: :json
        end.to change(Invoice, :count).by(0)
      end

      it 'renders a JSON response with errors for the new api_v1_company_branch_office' do
        post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
             params: { invoice: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
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
               params: { invoice: valid_attributes_card_paid }, as: :json
        end.to change(Invoice, :count).by(1)
      end

      it 'does not create a new Invoice' do
        expect do
          post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
               params: { invoice: invalid_attributes_card_paid }, as: :json
        end.to change(Invoice, :count).by(0)
      end

      context 'card and cash paid' do
        it 'create new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: { invoice: valid_attributes_cash_and_card_paid }, as: :json
          end.to change(Invoice, :count).by(1)
        end
  
        it 'does not create a new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: { invoice: invalid_attributes_cash_and_card_paid }, as: :json
          end.to change(Invoice, :count).by(0)
        end
      end

      context 'card and qr paid' do
        it 'create new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: { invoice: valid_attributes_card_and_qr_paid }, as: :json
          end.to change(Invoice, :count).by(1)
        end
  
        it 'does not create a new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: { invoice: invalid_attributes_card_and_qr_paid }, as: :json
          end.to change(Invoice, :count).by(0)
        end
      end

      context 'card and gift card paid' do
        it 'create new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: { invoice: valid_attributes_card_and_gift_card_paid }, as: :json
          end.to change(Invoice, :count).by(1)
        end
  
        it 'does not create a new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: { invoice: invalid_attributes_card_and_gift_card_paid }, as: :json
          end.to change(Invoice, :count).by(0)
        end
      end

      context 'card and online paid' do
        it 'create new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: { invoice: valid_attributes_card_and_online_paid }, as: :json
          end.to change(Invoice, :count).by(1)
        end
  
        it 'does not create a new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: { invoice: invalid_attributes_card_and_online_paid }, as: :json
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
               params: { invoice: valid_attributes_qr_paid }, as: :json
        end.to change(Invoice, :count).by(1)
      end

      it 'does not create a new Invoice' do
        expect do
          post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
               params: { invoice: invalid_attributes_qr_paid }, as: :json
        end.to change(Invoice, :count).by(0)
      end

      context 'qr and cash paid' do
        it 'create new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: { invoice: valid_attributes_qr_and_cash_paid }, as: :json
          end.to change(Invoice, :count).by(1)
        end
  
        it 'does not create a new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: { invoice: invalid_attributes_qr_and_cash_paid }, as: :json
          end.to change(Invoice, :count).by(0)
        end
      end

      context 'qr and gift card paid' do
        it 'create new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: { invoice: valid_attributes_qr_and_gift_card_paid }, as: :json
          end.to change(Invoice, :count).by(1)
        end
  
        it 'does not create a new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: { invoice: invalid_attributes_qr_and_gift_card_paid }, as: :json
          end.to change(Invoice, :count).by(0)
        end
      end

      context 'qr and online paid' do
        it 'create new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: { invoice: valid_attributes_qr_and_online_paid }, as: :json
          end.to change(Invoice, :count).by(1)
        end
  
        it 'does not create a new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: { invoice: invalid_attributes_qr_and_online_paid }, as: :json
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
               params: { invoice: valid_attributes_online_paid }, as: :json
        end.to change(Invoice, :count).by(1)
      end

      it 'does not create a new Invoice' do
        expect do
          post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
               params: { invoice: invalid_attributes_online_paid }, as: :json
        end.to change(Invoice, :count).by(0)
      end

      context 'online and cash paid' do
        it 'create new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: { invoice: valid_attributes_online_and_cash_paid }, as: :json
          end.to change(Invoice, :count).by(1)
        end
  
        it 'does not create a new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: { invoice: invalid_attributes_online_and_cash_paid }, as: :json
          end.to change(Invoice, :count).by(0)
        end
      end

      context 'online and cash paid' do
        it 'create new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: { invoice: valid_attributes_online_and_cash_paid }, as: :json
          end.to change(Invoice, :count).by(1)
        end
  
        it 'does not create a new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: { invoice: invalid_attributes_online_and_cash_paid }, as: :json
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
               params: { invoice: valid_attributes_gift_card_paid }, as: :json
        end.to change(Invoice, :count).by(1)
      end

      it 'does not create a new Invoice' do
        expect do
          post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
               params: { invoice: invalid_attributes_gift_card_paid }, as: :json
        end.to change(Invoice, :count).by(0)
      end

      context 'gift card and cash paid' do
        it 'create new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: { invoice: valid_attributes_gift_card_and_cash_paid }, as: :json
          end.to change(Invoice, :count).by(1)
        end
  
        it 'does not create a new Invoice' do
          expect do
            post api_v1_branch_office_invoices_url(branch_office_id: branch_office.id),
                 params: { invoice: invalid_attributes_gift_card_and_cash_paid }, as: :json
          end.to change(Invoice, :count).by(0)
        end
      end
    end
  end
end