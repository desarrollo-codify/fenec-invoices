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

  describe 'company_nit attribute' do
    it { validate_presence_of(:company_nit) }

    context 'with nil value' do
      let(:invoice) { build(:invoice, default_values: true, company_nit: nil) }

      it 'is invalid' do
        expect(invoice).to_not be_valid
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
  end

  describe 'municipality attribute' do
    it { validate_presence_of(:municipality) }

    context 'with nil or empty value' do
      let(:invoice) { build(:invoice, municipality: nil) }

      it 'is invalid' do
        expect(invoice).to_not be_valid
        invoice.municipality = ''
        expect(invoice).to_not be_valid
      end
    end

    context 'with special characters' do
      let(:invoice) { build(:invoice, municipality: '$%^') }

      it 'is not valid' do
        expect(invoice).to_not be_valid
      end
    end

    context 'with allowed characters' do
      let(:invoice) { build(:invoice, municipality: 'áü -_.') }

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

  describe 'cufd_code attribute' do
    it { validate_presence_of(:phone) }

    context 'with nil or empty value' do
      let(:invoice) { build(:invoice, cufd_code: nil) }

      it 'is invalid' do
        expect(invoice).to_not be_valid
        invoice.cufd_code = ''
        expect(invoice).to_not be_valid
      end
    end
  end

  describe 'address attribute' do
    it { validate_presence_of(:address) }

    context 'with nil or empty value' do
      let(:invoice) { build(:invoice, address: nil) }

      it 'is invalid' do
        expect(invoice).to_not be_valid
        invoice.address = ''
        expect(invoice).to_not be_valid
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
  end

  describe 'document_type attribute' do
    it { validate_presence_of(:document_type) }

    context 'with nil value' do
      let(:invoice) { build(:invoice, document_type: nil) }

      it 'is not valid' do
        expect(invoice).to_not be_valid
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

    context 'validates numericality in business_nit if document_type is 1 or 5' do
      context 'document_type 1' do
        let(:invoice) { build(:invoice, default_values: true, business_nit: '123a', document_type: 1) }

        it 'is invalid' do
          expect(invoice).to_not be_valid
          expect(invoice.errors[:business_nit]).to eq(['El número de documento debe ser numérico.'])
        end
      end

      context 'document_type 5' do
        let(:invoice) { build(:invoice, default_values: true, business_nit: '123a', document_type: 5) }

        it 'is invalid' do
          expect(invoice).to_not be_valid
          expect(invoice.errors[:business_nit]).to eq(['El número de documento debe ser numérico.'])
        end
      end
    end
  end

  describe 'client_code attribute' do
    it { validate_presence_of(:client_code) }

    context 'with nil value' do
      let(:invoice) { build(:invoice, client_code: nil) }

      it 'is not valid' do
        expect(invoice).to_not be_valid
      end
    end
  end

  describe 'payment_method attribute' do
    it { validate_presence_of(:payment_method) }

    context 'with nil value' do
      let(:invoice) { build(:invoice, payment_method: nil) }

      it 'is not valid' do
        expect(invoice).to_not be_valid
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
        let(:invoice) { build(:invoice, subtotal: 10, discount: 1, gift_card_total: 1, advance: 1, total: 8, cash_paid: 8) }

        it 'is not valid' do
          expect(invoice).to_not be_valid
          expect(invoice.errors[:total]).to include('El total pagado no concuerda con el total a pagar.')
        end
      end

      context 'with valid calculation' do
        let(:invoice) do
          build(:invoice, default_values: true, business_name: 'Abc', subtotal: 10, discount: 1, gift_card_total: 1, advance: 1,
                          total: 8, cash_paid: 7, amount_payable: 7)
        end

        it 'is valid' do
          expect(invoice).to be_valid
        end
      end
    end
  end

  describe 'currency_code attribute' do
    it { validate_presence_of(:currency_code) }

    context 'with nil value' do
      let(:invoice) { build(:invoice, currency_code: nil) }

      it 'is not valid' do
        expect(invoice).to_not be_valid
      end
    end
  end

  describe 'exchange_rate attribute' do
    it { validate_presence_of(:exchange_rate) }

    context 'with nil value' do
      let(:invoice) { build(:invoice, exchange_rate: nil) }

      it 'is not valid' do
        expect(invoice).to_not be_valid
      end
    end
  end

  describe 'currency_total attribute' do
    it { validate_presence_of(:currency_total) }

    context 'with nil value' do
      let(:invoice) { build(:invoice, currency_total: nil) }

      it 'is not valid' do
        expect(invoice).to_not be_valid
      end
    end
  end

  describe 'legend attribute' do
    it { validate_presence_of(:legend) }

    context 'with nil or empty value' do
      let(:invoice) { build(:invoice, legend: nil) }

      it 'is invalid' do
        expect(invoice).to_not be_valid
        invoice.legend = ''
        expect(invoice).to_not be_valid
      end
    end
  end

  describe 'user attribute' do
    it { validate_presence_of(:user) }

    context 'with nil or empty value' do
      let(:invoice) { build(:invoice, user: nil) }

      it 'is invalid' do
        expect(invoice).to_not be_valid
        invoice.user = ''
        expect(invoice).to_not be_valid
      end
    end
  end

  describe 'document_sector_code attribute' do
    it { validate_presence_of(:document_sector_code) }

    context 'with nil or empty value' do
      let(:invoice) { build(:invoice, document_sector_code: nil) }

      it 'is invalid' do
        expect(invoice).to_not be_valid
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

  describe 'discount attribute' do
    context 'validates discount not greater than subtotal' do
      let(:invoice) { build(:invoice, total: 1, subtotal: 1, discount: 2) }

      it 'is invalid' do
        expect(invoice).to_not be_valid
        expect(invoice.errors[:discount]).to eq(['Descuento no puede ser mayor al subtotal.'])
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
        expect(invoice.gift_card_total).to eq(0)
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
      let(:measurement) { Measurement.create!(description: 'ABC') }
      let(:product) do
        Product.create!(primary_code: 'ABC', description: 'ABC', company_id: company.id, measurement_id: measurement.id)
      end

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
      let(:invoice) { build(:invoice, total: 3, subtotal: 3, qr_paid: 1, cash_paid: 1, card_paid: 1, amount_payable: 3) }

      it 'is valid' do
        expect(invoice).to be_valid
      end
    end
  end

  describe 'for_sending scope' do
    context 'with include or not invoices for sending' do
      let(:for_sending) { create(:invoice, branch_office: branch_office, invoice_status: invoice_status, number: 3) }
      let(:send) { create(:invoice, branch_office: branch_office, invoice_status: invoice_status, number: 2, sent_at: DateTime.now) }

      it 'Includes only the expected invoice' do
        expect(Invoice.for_sending).to include(for_sending)
        expect(Invoice.for_sending).to_not include(send)
      end
    end
  end

  describe 'by_cufd scope' do
    context 'with include or not invoices for sending' do
      before(:all) do
        @cufd_code = 'ABCD1234'
      end
      let(:cufd) { create(:invoice, branch_office: branch_office, invoice_status: invoice_status, number: 3, cufd_code: @cufd_code) }
      let(:non_cufd) do
        create(:invoice, branch_office: branch_office, invoice_status: invoice_status, number: 2, sent_at: DateTime.now)
      end

      it 'Includes only the expected invoice' do
        expect(Invoice.by_cufd(@cufd_code)).to include(cufd)
        expect(Invoice.by_cufd(@cufd_code)).to_not include(non_cufd)
      end
    end
  end

  describe 'for_sendig_cancel scope' do
    before { create(:cancellation_reason) }
    context 'with include or not invoices for sending cancel' do
      let(:for_sendig_cancel) do
        create(:invoice, branch_office: branch_office, invoice_status: invoice_status, number: 3, cancellation_reason_id: 1)
      end
      let(:non_cancel) { create(:invoice, branch_office: branch_office, invoice_status: invoice_status, number: 2) }

      it 'Includes only the expected invoice' do
        expect(Invoice.for_sending_cancel).to include(for_sendig_cancel)
        expect(Invoice.for_sending_cancel).to_not include(non_cancel)
      end
    end
  end
end
