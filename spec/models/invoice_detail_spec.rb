# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoiceDetail, type: :model do
  let(:company) { Company.create!(name: 'Codify', nit: '123', address: 'Anywhere') }
  let(:product) { Product.create!(primary_code: 'ABC', description: 'ABC', company_id: company.id) }
  let(:measurement) { Measurement.create!(description: 'ABC') }
  let(:branch_office) do
    BranchOffice.create!(name: 'Sucursal 1', number: 1, city: 'Santa Cruz', company_id: company.id)
  end
  let(:invoice_status) { InvoiceStatus.create!(description: 'Good') }
  let(:invoice) do
    Invoice.create!(date: '2022-01-01', business_name: 'Codify', company_name: 'SRL', business_nit: '123', number: 1,
                    subtotal: 10, total: 10, cash_paid: 10,
                    branch_office_id: branch_office.id, invoice_status_id: invoice_status.id)
  end

  subject do
    described_class.new(description: 'ABC', unit_price: 1, quantity: 1, subtotal: 1, discount: 0, total: 1,
                        product_id: product.id, invoice_id: invoice.id, measurement_id: measurement.id)
  end

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with invalid value' do
      let(:invoice_detail) do
        described_class.new(unit_price: 1, quantity: 1, subtotal: 1, discount: 0, total: 1,
                            product_id: product.id, invoice_id: invoice.id, measurement_id: measurement.id)
      end

      it 'is invalid' do
        expect(invoice_detail).to_not be_valid
        invoice_detail.description = ''
        expect(invoice_detail).to_not be_valid
      end
    end

    context 'with special characters' do
      let(:invoice_detail) do
        described_class.new(description: '$%^', unit_price: 1, quantity: 1, subtotal: 1, discount: 0, total: 1,
                            product_id: product.id, invoice_id: invoice.id, measurement_id: measurement.id)
      end

      it 'is not valid' do
        expect(invoice_detail).to_not be_valid
      end
    end

    context 'with allowed characters' do
      let(:invoice_detail) do
        described_class.new(description: 'áu .-_', unit_price: 1, quantity: 1, subtotal: 1, discount: 0, total: 1,
                            product_id: product.id, invoice_id: invoice.id, measurement_id: measurement.id)
      end

      it 'is valid' do
        expect(invoice_detail).to be_valid
      end
    end
  end

  describe 'unit_price attribute' do
    it { validate_presence_of(:unit_price) }

    context 'with invalid value' do
      let(:invoice_detail) do
        described_class.new(description: 'ABC', quantity: 1, subtotal: 1, discount: 0, total: 1,
                            product_id: product.id, invoice_id: invoice.id, measurement_id: measurement.id)
      end

      it 'is invalid' do
        expect(invoice_detail).to_not be_valid
      end
    end

    context 'validates numericality of unit price' do
      it { validate_numericality_of(:invoice_detail).is_greater_than_or_equal_to(0) }

      context 'with non-numeric value' do
        let(:invoice_detail) do
          described_class.new(description: 'ABC', unit_price: 'A', quantity: 1, subtotal: 1, discount: 0, total: 1,
                              product_id: product.id, invoice_id: invoice.id, measurement_id: measurement.id)
        end

        it 'is invalid' do
          expect(invoice_detail).to_not be_valid
          invoice_detail.unit_price = -1
          expect(invoice_detail.errors[:unit_price]).to eq(['Precio unitario debe ser mayor o igual a 0.'])
        end
      end
    end
  end

  describe 'quantity attribute' do
    it { validate_presence_of(:quantity) }

    context 'with invalid value' do
      let(:invoice_detail) do
        described_class.new(description: 'ABC', unit_price: 1, subtotal: 1, discount: 0, total: 1,
                            product_id: product.id, invoice_id: invoice.id, measurement_id: measurement.id)
      end

      it 'it has a valid default value' do
        expect(invoice_detail).to be_valid
      end
    end

    context 'validates numericality of quantity' do
      it { validate_numericality_of(:quantity).is_greater_than_or_equal_to(0) }

      context 'with non-numeric value' do
        let(:invoice_detail) do
          described_class.new(description: 'ABC', unit_price: 1, quantity: 'A', subtotal: 1, discount: 0, total: 1,
                              product_id: product.id, invoice_id: invoice.id, measurement_id: measurement.id)
        end

        it 'is invalid' do
          expect(invoice_detail).to_not be_valid
          invoice_detail.quantity = -1
          expect(invoice_detail.errors[:quantity]).to eq(['Cantidad debe ser mayor o igual a 0.'])
        end
      end
    end
  end

  describe 'subtotal attribute' do
    it { validate_presence_of(:subtotal) }

    context 'with invalid value' do
      let(:invoice_detail) do
        described_class.new(description: 'ABC', unit_price: 1, quantity: 1, discount: 0, total: 1,
                            product_id: product.id, invoice_id: invoice.id, measurement_id: measurement.id)
      end

      it 'is invalid' do
        expect(invoice_detail).to_not be_valid
      end
    end

    context 'validates numericality of subtotal' do
      it { validate_numericality_of(:subtotal).is_greater_than_or_equal_to(0) }

      context 'with non-numeric value' do
        let(:invoice_detail) do
          described_class.new(description: 'ABC', unit_price: 1, quantity: 1, subtotal: 'A', discount: 0, total: 1,
                              product_id: product.id, invoice_id: invoice.id, measurement_id: measurement.id)
        end

        it 'is invalid' do
          expect(invoice_detail).to_not be_valid
          invoice_detail.subtotal = -1
          expect(invoice_detail.errors[:subtotal]).to include('Subtotal debe ser mayor o igual a 0.')
        end
      end
    end

    context 'validates calculation' do
      context 'with invalid calculation' do
        let(:invoice_detail) do
          described_class.new(description: 'ABC', unit_price: 1, quantity: 2, subtotal: 1, total: 1,
                              product_id: product.id, invoice_id: invoice.id, measurement_id: measurement.id)
        end

        it 'is not valid' do
          expect(invoice_detail).to_not be_valid
          expect(invoice_detail.errors[:subtotal]).to include('El subtotal no esta calculado correctamente.')
        end
      end

      context 'with valid calculation' do
        let(:invoice_detail) do
          described_class.new(description: 'ABC', unit_price: 1, quantity: 2, subtotal: 2, total: 2,
                              product_id: product.id, invoice_id: invoice.id, measurement_id: measurement.id)
        end

        it 'is valid' do
          expect(invoice_detail).to be_valid
        end
      end
    end
  end

  describe 'discount attribute' do
    it { validate_presence_of(:discount) }

    context 'with invalid value' do
      let(:invoice_detail) do
        described_class.new(description: 'ABC', unit_price: 1, quantity: 1, subtotal: 1, total: 1,
                            product_id: product.id, invoice_id: invoice.id, measurement_id: measurement.id)
      end

      it 'it has a valid default value' do
        expect(invoice_detail).to be_valid
      end
    end

    context 'validates numericality of discount' do
      it { validate_numericality_of(:discount).is_greater_than_or_equal_to(0) }

      context 'with non-numeric value' do
        let(:invoice_detail) do
          described_class.new(description: 'ABC', unit_price: 1, quantity: 1, subtotal: 1, discount: 'A', total: 1,
                              product_id: product.id, invoice_id: invoice.id, measurement_id: measurement.id)
        end

        it 'is invalid' do
          expect(invoice_detail).to_not be_valid
          invoice_detail.discount = -1
          expect(invoice_detail.errors[:discount]).to eq(['Descuento debe ser mayor o igual a 0.'])
        end
      end
    end

    context 'validates discount not greater than subtotal' do
      let(:invoice_detail) do
        described_class.new(description: 'ABC', unit_price: 1, quantity: 1, subtotal: 1, discount: 2, total: 1,
                            product_id: product.id, invoice_id: invoice.id, measurement_id: measurement.id)
      end

      it 'is invalid' do
        expect(invoice_detail).to_not be_valid
        expect(invoice_detail.errors[:discount]).to eq(['Descuento no puede ser mayor al subtotal'])
      end
    end
  end

  describe 'total attribute' do
    it { validate_presence_of(:total) }

    context 'with invalid value' do
      let(:invoice_detail) do
        described_class.new(description: 'ABC', unit_price: 1, quantity: 1, discount: 0, subtotal: 1,
                            product_id: product.id, invoice_id: invoice.id, measurement_id: measurement.id)
      end

      it 'is invalid' do
        expect(invoice_detail).to_not be_valid
      end
    end

    context 'validates numericality of total' do
      it { validate_numericality_of(:total).is_greater_than_or_equal_to(0) }

      context 'with non-numeric value' do
        let(:invoice_detail) do
          described_class.new(description: 'ABC', unit_price: 1, quantity: 1, subtotal: 1, discount: 0, total: 'A',
                              product_id: product.id, invoice_id: invoice.id, measurement_id: measurement.id)
        end

        it 'is invalid' do
          expect(invoice_detail).to_not be_valid
          invoice_detail.total = -1
          expect(invoice_detail.errors[:total]).to include('Total debe ser mayor o igual a 0.')
        end
      end
    end

    context 'validates calculation' do
      context 'with invalid calculation' do
        let(:invoice_detail) do
          described_class.new(description: 'ABC', unit_price: 1, quantity: 2, subtotal: 2,
                              discount: 1, total: 2,
                              product_id: product.id, invoice_id: invoice.id, measurement_id: measurement.id)
        end

        it 'is not valid' do
          expect(invoice_detail).to_not be_valid
          expect(invoice_detail.errors[:total]).to include('El total no esta calculado correctamente.')
        end
      end

      context 'with valid calculation' do
        let(:invoice_detail) do
          described_class.new(description: 'ABC', unit_price: 1, quantity: 2, subtotal: 2,
                              discount: 1, total: 1,
                              product_id: product.id, invoice_id: invoice.id, measurement_id: measurement.id)
        end

        it 'is valid' do
          expect(invoice_detail).to be_valid
        end
      end
    end
  end

  describe 'product_id attribute' do
    context 'with invalid value' do
      let(:invoice_detail) do
        described_class.new(description: 'ABC', unit_price: 1, quantity: 1, discount: 0, subtotal: 1,
                            total: 1, invoice_id: invoice.id, measurement_id: measurement.id)
      end

      it 'is invalid' do
        expect(invoice_detail).to_not be_valid
      end
    end
  end

  describe 'measurement_id attribute' do
    context 'with invalid value' do
      let(:invoice_detail) do
        described_class.new(description: 'ABC', unit_price: 1, quantity: 1, discount: 0, subtotal: 1,
                            total: 1, invoice_id: invoice.id, product_id: product.id)
      end

      it 'is invalid' do
        expect(invoice_detail).to_not be_valid
      end
    end
  end

  describe 'invoice_id attribute' do
    context 'with invalid value' do
      let(:invoice_detail) do
        described_class.new(description: 'ABC', unit_price: 1, quantity: 1, discount: 0, subtotal: 1,
                            total: 1, product_id: product.id, measurement_id: measurement.id)
      end

      it 'is invalid' do
        expect(invoice_detail).to_not be_valid
      end
    end
  end

  describe '#default_values' do
    context 'with missing values' do
      let(:invoice) { described_class.new }

      it 'has default values' do
        expect(invoice.discount).to eq(0)
        expect(invoice.quantity).to eq(1)
      end
    end
  end
end
