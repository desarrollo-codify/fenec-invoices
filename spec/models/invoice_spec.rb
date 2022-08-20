# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invoice, type: :model do
  let(:branch_office) do
    BranchOffice.create!(name: 'Sucursal 1', number: 1, city: 'Santa Cruz', company_id: company.id)
  end
  let(:invoice_status) { InvoiceStatus.create!(description: 'Good') }
  let(:company) { Company.create!(name: 'Codify', nit: '123', address: 'Anywhere') }

  subject { build(:invoice, branch_office: branch_office, invoice_status: invoice_status) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'business_name attribute' do
    it { validate_presence_of(:business_name) }

    context 'with nil or emtpy value' do
      let(:invoice) { build(:invoice, default_values: true, business_name: nil) }

      it 'is invalid' do
        expect(invoice).to_not be_valid
        invoice.business_name = ''
        expect(invoice).to_not be_valid
      end
    end

    context 'with special characters' do
      let(:invoice) { build(:invoice, default_values: true, business_name: '@#$') }

      it 'is not valid' do
        expect(invoice).to_not be_valid
      end
    end

    context 'with allowed characters' do
      let(:invoice) { build(:invoice, business_name: 'áü -_.') }

      it 'is valid' do
        expect(invoice).to be_valid
      end
    end
  end

  describe 'business_nit attribute' do
    it { validate_presence_of(:business_nit) }

    context 'with nil value' do
      let(:invoice) { build(:invoice, default_values: true, business_nit: nil) }

      it 'is invalid' do
        expect(invoice).to_not be_valid
      end
    end

    context 'validates numericality of business nit' do
      it { validate_numericality_of(:business_nit).only_integer }

      context 'with non-numeric value' do
        let(:invoice) { build(:invoice, default_values: true, business_nit: 'A') }

        it 'is invalid' do
          expect(invoice).to_not be_valid
          expect(invoice.errors[:business_nit]).to eq ['El NIT debe ser un valor numérico.']
        end
      end
    end
  end

  describe 'company_name attribute' do
    it { validate_presence_of(:company_name) }

    context 'with nil or empty value' do
      let(:invoice) { build(:invoice, company_name: nil) }

      it 'is invalid' do
        expect(invoice).to_not be_valid
        invoice.company_name = ''
        expect(invoice).to_not be_valid
      end
    end

    context 'with special characters' do
      let(:invoice) { build(:invoice, company_name: '$%^') }

      it 'is not valid' do
        expect(invoice).to_not be_valid
      end
    end

    context 'with allowed characters' do
      let(:invoice) { build(:invoice, company_name: 'áü -_.') }

      it 'is valid' do
        expect(invoice).to be_valid
      end
    end
  end

  describe 'number attribute' do
    context 'validates uniqueness of number per invoice' do
      context 'with duplicated number' do
        before { create(:invoice, branch_office: branch_office) }

        it 'is invalid when number is duplicated' do
          expect(subject).to_not be_valid
          expect(subject.errors[:number])
            .to eq ['Ya existe este número de factura con el código único de facturación diaria.']
        end
      end

      context 'with different number' do
        before { create(:invoice, branch_office: branch_office, number: 2) }

        it 'is valid' do
          expect(subject).to be_valid
        end
      end
    end
  end

  describe 'subtotal attribute' do
    it { validate_presence_of(:subtotal) }

    context 'with nil value' do
      let(:invoice) { build(:invoice, subtotal: nil) }

      it 'is not valid' do
        expect(invoice).to_not be_valid
      end
    end

    context 'validate numericality of subtotal' do
      it { validate_numericality_of(:subtotal).only_integer }

      context 'with non-numeric value' do
        let(:invoice) { build(:invoice, subtotal: 'A') }

        it 'is not invalid' do
          expect(invoice).to_not be_valid
          expect(invoice.errors[:subtotal]).to eq ['El subtotal debe ser un valor numérico.']
        end
      end
    end
  end

  describe 'total attribute' do
    it { validate_presence_of(:total) }

    context 'with nil value' do
      let(:invoice) { build(:invoice, total: nil) }

      it 'is not valid' do
        expect(invoice).to_not be_valid
      end
    end

    context 'validate numericality of total' do
      it { validate_numericality_of(:total).only_integer }

      context 'with non-numeric value' do
        let(:invoice) { build(:invoice, total: 'A') }

        it 'is not valid' do
          expect(invoice).to_not be_valid
          expect(invoice.errors[:total]).to include('El total debe ser un valor numérico.')
        end
      end
    end

    context 'validates calculation of total' do
      context 'with invalid calculation' do
        let(:invoice) { build(:invoice, subtotal: 10, discount: 1, gift_card: 1, advance: 1, total: 8, cash_paid: 8) }

        it 'is not valid' do
          expect(invoice).to_not be_valid
          expect(invoice.errors[:total]).to include('El monto total no concuerda con el calculo realizado.')
        end
      end

      context 'with valid calculation' do
        let(:invoice) do
          build(:invoice, default_values: true, business_name: 'Abc', subtotal: 10, discount: 1, gift_card: 1, advance: 1,
                          total: 7, cash_paid: 7)
        end

        it 'is valid' do
          expect(invoice).to be_valid
        end
      end
    end
  end

  describe 'discount attribute' do
    context 'validates discount not greater than subtotal' do
      let(:invoice) { build(:invoice, total: 1, subtotal: 1, discount: 2) }

      it 'is invalid' do
        expect(invoice).to_not be_valid
        expect(invoice.errors[:discount]).to eq(['Descuento no puede ser mayor al subtotal.'])
      end
    end
  end

  describe 'date attribute' do
    it { validate_presence_of(:date) }

    context 'with nil value' do
      let(:invoice) { build(:invoice, date: nil) }

      it 'is not valid' do
        expect(invoice).to_not be_valid
      end
    end
  end

  describe 'branch_office_id attribute' do
    context 'with nil value' do
      let(:invoice) { build(:invoice, branch_office: nil) }

      it 'is not valid' do
        expect(invoice).to_not be_valid
      end
    end
  end

  describe 'invoice_status_id attribute' do
    context 'with nil value' do
      let(:invoice) { build(:invoice, invoice_status: nil) }

      it 'is not valid' do
        expect(invoice).to_not be_valid
      end
    end
  end

  describe '#default_values' do
    context 'with missing values' do
      let(:invoice) { build(:invoice, default_values: true) }

      it 'has default values' do
        expect(invoice.discount).to eq(0)
        expect(invoice.gift_card).to eq(0)
        expect(invoice.advance).to eq(0)
        expect(invoice.cash_paid).to eq(0)
        expect(invoice.online_paid).to eq(0)
        expect(invoice.qr_paid).to eq(0)
        expect(invoice.card_paid).to eq(0)
        expect(invoice.business_name).to eq('S/N')
        expect(invoice.business_nit).to eq('0')
      end
    end
  end

  describe 'validates dependent destroy for invoice details' do
    it { expect(subject).to have_many(:invoice_details).dependent(:destroy) }

    context 'when deleting an invoice' do
      let(:invoice) { create(:invoice, branch_office: branch_office) }
      let(:company) { Company.create!(name: 'Codify', nit: '123', address: 'Anywhere') }
      let(:product) { Product.create!(primary_code: 'ABC', description: 'ABC', company_id: company.id) }
      let(:measurement) { Measurement.create!(description: 'ABC') }

      before { create(:invoice_detail, product: product, invoice: invoice) }

      it 'destroys the detail' do
        expect { invoice.destroy }.to change { InvoiceDetail.count }.by(-1)
      end
    end
  end

  describe 'validates total paid' do
    context 'with wrong calculation' do
      let(:invoice) { build(:invoice, total: 2, subtotal: 2, qr_paid: 1, cash_paid: 1, card_paid: 1) }

      it 'is not valid' do
        expect(invoice).to_not be_valid
        expect(invoice.errors[:total]).to eq(['El total pagado no concuerda con el total a pagar.'])
      end
    end

    context 'with correct calculation' do
      let(:invoice) { build(:invoice, total: 3, subtotal: 3, qr_paid: 1, cash_paid: 1, card_paid: 1) }

      it 'is valid' do
        expect(invoice).to be_valid
      end
    end
  end
end
