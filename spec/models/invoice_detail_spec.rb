# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoiceDetail, type: :model do
  it { is_expected.to belong_to(:invoice) }
  it { is_expected.to belong_to(:product) }
  it { is_expected.to belong_to(:measurement) }

  let(:company) { create(:company) }
  let(:product) { create(:product, company: company) }
  let(:measurement) { create(:measurement) }
  let(:branch_office) { create(:branch_office, company: company) }
  let(:invoice_status) { create(:invoice_status) }
  let(:invoice) { create(:invoice, branch_office: branch_office, invoice_status: invoice_status) }

  subject { build(:invoice_detail, invoice: invoice, measurement: measurement) }
  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'economic_activity_code attribute' do
    it { validate_presence_of(:economic_activity_code) }

    context 'with nil value' do
      let(:invoice_detail) { build(:invoice_detail, economic_activity_code: nil) }

      it 'is invalid' do
        expect(invoice_detail).to_not be_valid
      end
    end
  end

  describe 'product_code attribute' do
    it { validate_presence_of(:product_code) }

    context 'with nil value' do
      let(:invoice_detail) { build(:invoice_detail, product_code: nil) }

      it 'is invalid' do
        expect(invoice_detail).to_not be_valid
        invoice_detail.product_code = ''
        expect(invoice_detail).to_not be_valid
      end
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:invoice_detail) { build(:invoice_detail, description: nil) }

      it 'is invalid' do
        expect(invoice_detail).to_not be_valid
        invoice_detail.description = ''
        expect(invoice_detail).to_not be_valid
      end
    end

    context 'with special characters' do
      let(:invoice_detail) { build(:invoice_detail, description: '$%^') }

      it 'is not valid' do
        expect(invoice_detail).to_not be_valid
      end
    end

    context 'with allowed characters' do
      let(:invoice_detail) { build(:invoice_detail, description: 'áu .-_') }

      it 'is valid' do
        expect(invoice_detail).to be_valid
      end
    end
  end

  describe 'quantity attribute' do
    it { validate_presence_of(:quantity) }

    context 'with nil value' do
      let(:invoice_detail) { build(:invoice_detail, quantity: nil, default_values: true) }

      it 'it is not valid' do
        expect(invoice_detail).not_to be_valid
      end
    end

    context 'validates numericality of quantity' do
      it { validate_numericality_of(:quantity).is_greater_than_or_equal_to(0) }

      context 'with non-numeric value' do
        let(:invoice_detail) { build(:invoice_detail, default_values: true, quantity: 'A') }

        it 'is invalid' do
          expect(invoice_detail).to_not be_valid
          invoice_detail.quantity = -1
          expect(invoice_detail.errors[:quantity]).to eq(['Cantidad debe ser mayor o igual a 0.'])
        end
      end
    end
  end

  describe 'unit_price attribute' do
    it { validate_presence_of(:unit_price) }

    context 'with nil value' do
      let(:invoice_detail) { build(:invoice_detail, unit_price: nil) }

      it 'is invalid' do
        expect(invoice_detail).to_not be_valid
      end
    end

    context 'validates numericality of unit price' do
      it { validate_numericality_of(:invoice_detail).is_greater_than_or_equal_to(0) }

      context 'with non-numeric or lower than zero value' do
        let(:invoice_detail) { build(:invoice_detail, unit_price: 'A') }

        it 'is not valid' do
          expect(invoice_detail).to_not be_valid
          invoice_detail.unit_price = -1
          expect(invoice_detail.errors[:unit_price]).to eq(['Precio unitario debe ser mayor o igual a 0.'])
        end
      end
    end
  end

  describe 'subtotal attribute' do
    it { validate_presence_of(:subtotal) }

    context 'with nil value' do
      let(:invoice_detail) { build(:invoice_detail, subtotal: nil) }

      it 'is invalid' do
        expect(invoice_detail).to_not be_valid
      end
    end

    context 'validates numericality of subtotal' do
      it { validate_numericality_of(:subtotal).is_greater_than_or_equal_to(0) }

      context 'with non-numeric or lower than 0 value' do
        let(:invoice_detail) { build(:invoice_detail, subtotal: 'A') }

        it 'is invalid' do
          expect(invoice_detail).to_not be_valid
          invoice_detail.subtotal = -1
          expect(invoice_detail.errors[:subtotal]).to include('Subtotal debe ser mayor o igual a 0.')
        end
      end
    end

    context 'validates calculation' do
      context 'with invalid calculation' do
        let(:invoice_detail) { build(:invoice_detail, unit_price: 1, quantity: 2, subtotal: 1, total: 1, default_values: true) }

        it 'is not valid' do
          expect(invoice_detail).to_not be_valid
          expect(invoice_detail.errors[:subtotal]).to include('El subtotal no esta calculado correctamente.')
        end
      end

      context 'with valid calculation' do
        let(:invoice_detail) { build(:invoice_detail, unit_price: 1, quantity: 2, subtotal: 2, total: 2, default_values: true) }

        it 'is valid' do
          expect(invoice_detail).to be_valid
        end
      end
    end
  end

  describe 'discount attribute' do
    it { validate_presence_of(:discount) }

    context 'with nil value' do
      let(:invoice_detail) { build(:invoice_detail) }

      it 'it has a valid default value' do
        expect(invoice_detail).to be_valid
      end
    end

    context 'validates numericality of discount' do
      it { validate_numericality_of(:discount).is_greater_than_or_equal_to(0) }

      context 'with non-numeric value' do
        let(:invoice_detail) { build(:invoice_detail, discount: 'A', default_values: true) }

        it 'is invalid' do
          expect(invoice_detail).to_not be_valid
          invoice_detail.discount = -1
          expect(invoice_detail.errors[:discount]).to eq(['Descuento debe ser mayor o igual a 0.'])
        end
      end
    end

    context 'validates discount not greater than subtotal' do
      let(:invoice_detail) do
        build(:invoice_detail, unit_price: 1, quantity: 1, subtotal: 1, discount: 2, total: 1, default_values: true)
      end

      it 'is invalid' do
        expect(invoice_detail).to_not be_valid
        expect(invoice_detail.errors[:discount]).to eq(['Descuento no puede ser mayor al subtotal'])
      end
    end
  end

  describe 'total attribute' do
    it { validate_presence_of(:total) }

    context 'with nil value' do
      let(:invoice_detail) { build(:invoice_detail, total: nil) }

      it 'is invalid' do
        expect(invoice_detail).to_not be_valid
      end
    end

    context 'validates numericality of total' do
      it { validate_numericality_of(:total).is_greater_than_or_equal_to(0) }

      context 'with non-numeric or lower than zero value' do
        let(:invoice_detail) { build(:invoice_detail, total: 'A') }

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
          build(:invoice_detail, unit_price: 1, quantity: 2, subtotal: 2, discount: 1, total: 2, default_values: true)
        end

        it 'is not valid' do
          expect(invoice_detail).to_not be_valid
          expect(invoice_detail.errors[:total]).to include('El total no esta calculado correctamente.')
        end
      end

      context 'with valid calculation' do
        let(:invoice_detail) do
          build(:invoice_detail, unit_price: 1, quantity: 2, subtotal: 2, discount: 1, total: 1, default_values: true)
        end

        it 'is valid' do
          expect(invoice_detail).to be_valid
        end
      end
    end
  end

  describe 'product_id attribute' do
    context 'with nil value' do
      let(:invoice_detail) { build(:invoice_detail, product: nil) }

      it 'is invalid' do
        expect(invoice_detail).to_not be_valid
      end
    end
  end

  describe 'measurement_id attribute' do
    context 'with nil value' do
      let(:invoice_detail) { build(:invoice_detail, measurement: nil) }

      it 'is invalid' do
        expect(invoice_detail).to_not be_valid
      end
    end
  end

  describe 'invoice_id attribute' do
    context 'with nil value' do
      let(:invoice_detail) { build(:invoice_detail, invoice: nil) }

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
