require 'rails_helper'

RSpec.describe Invoice, type: :model do
  subject { described_class.new(date: "12/08/2022", business_name: 'Codify', business_nit: '123', number: 1, subtotal: 10, total: 10, 
    branch_office_id: branch_office.id, invoice_status_id: invoice_status.id) }
  let(:branch_office) { BranchOffice.create!(name: 'Sucursal 1', number: 1, city: 'Santa Cruz', company_id: company.id) }
  let(:invoice_status) { InvoiceStatus.create!(description: 'Good') }
  let(:company) { Company.create!(name: 'Codify', nit: '123', address: 'Anywhere') }

  
  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'business_name attribute' do
    it { validate_presence_of(:business_name) }
    
    context 'with invalid value' do
      let(:invoice) { described_class.new(date: "12/08/2022", business_name: '', business_nit: '123', number: 1, subtotal: 10, total: 10, 
        branch_office_id: branch_office.id, invoice_status_id: invoice_status.id) 
      }

      it 'is invalid' do
        expect(invoice).to_not be_valid
        invoice.business_name = ''
        expect(invoice).to_not be_valid
      end
    end
  end

  describe 'business_nit attribute' do
    it { validate_presence_of(:business_nit) }
    
    context 'with invalid value' do
      let(:invoice) { described_class.new(date: "12/08/2022", business_name: 'Juan', number: 1, subtotal: 10, total: 10, 
        branch_office_id: branch_office.id, invoice_status_id: invoice_status.id) 
      }

      it 'is invalid' do
        invoice.business_nit = nil
        expect(invoice).to_not be_valid
      end
    end

    context 'validates numericality of business nit' do
      it { validate_numericality_of(:business_nit).only_integer }
  
      context 'with non-numeric value' do
        subject { described_class.new(date: "12/08/2022", business_name: 'Codify', business_nit: 'ABC', number: 1, subtotal: 10, total: 10, 
          branch_office_id: branch_office.id, invoice_status_id: invoice_status.id) }
  
        it 'is invalid' do
          expect(subject).to_not be_valid
          expect(subject.errors[:business_nit]).to eq ['El NIT debe ser un valor numérico.']
        end
      end
    end
  end

  describe 'number attribute' do
    context 'validates uniqueness of number per invoice' do
      context 'with duplicated number' do
        before { described_class.create!(date: "12/08/2022", business_name: 'Codify', business_nit: '123', number: 1, subtotal: 10, total: 10, 
          branch_office_id: branch_office.id, invoice_status_id: invoice_status.id) }
  
        it 'is invalid when number is duplicated' do
          expect(subject).to_not be_valid
          expect(subject.errors[:number]).to eq ['Ya existe este número de factura con el código único de facturación diaria.']
        end
      end

      context 'with different number' do
        before { described_class.create!(date: "12/08/2022", business_name: 'Codify', business_nit: '123', number: 2, subtotal: 10, total: 10, 
          branch_office_id: branch_office.id, invoice_status_id: invoice_status.id) }
  
        it 'is valid' do
          expect(subject).to be_valid
        end
      end
    end
  end
  
  describe 'subtotal attribute' do
    it { validate_presence_of(:subtotal) }
    
    context 'with nil value' do
      let(:invoice) { described_class.new(date: "12/08/2022", business_name: 'Codify', business_nit: '123', number: 1, total: 10, 
        branch_office_id: branch_office.id, invoice_status_id: invoice_status.id) }

      it 'is not valid' do
        invoice.subtotal = nil
        expect(invoice).to_not be_valid
      end
    end

    context 'validate numericality of subtotal' do
      it { validate_numericality_of(:subtotal).only_integer }
  
      context 'with invalid value' do
        let(:invoice) { described_class.new(date: "12/08/2022", business_name: 'Codify', business_nit: '123', number: 1, subtotal: 'ABC', total: 10, 
          branch_office_id: branch_office.id, invoice_status_id: invoice_status.id) }
  
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
      let(:invoice) { described_class.new(date: "12/08/2022", business_name: 'Codify', business_nit: '123', number: 1, subtotal: 10, 
        branch_office_id: branch_office.id, invoice_status_id: invoice_status.id) }

      it 'is not valid' do
        invoice.total = nil
        expect(invoice).to_not be_valid
      end
    end

    context 'validate numericality of total' do
      it { validate_numericality_of(:total).only_integer }
  
      context 'with invalid value' do
        let(:invoice) { described_class.new(date: "12/08/2022", business_name: 'Codify', business_nit: '123', number: 1, total: 'ABC', subtotal: 10, 
          branch_office_id: branch_office.id, invoice_status_id: invoice_status.id) }
  
        it 'is not invalid' do
          expect(invoice).to_not be_valid
          expect(invoice.errors[:total]).to eq ['El total debe ser un valor numérico.']
        end
      end
    end
  end

  describe 'date attribute' do
    it { validate_presence_of(:date) }
    
    context 'with invalid values' do
      let(:invoice) { described_class.new(business_name: 'Codify', business_nit: '123', number: 1, subtotal: 10, branch_office_id: branch_office.id, 
        invoice_status_id: invoice_status.id) }

      it 'is not valid' do
        expect(invoice).to_not be_valid
      end
    end
  end

  describe 'branch_office_id attribute' do
    context 'with invalid values' do
      let(:invoice) { described_class.new(business_name: 'Codify', business_nit: '123', number: 1, subtotal: 10, date: "12/08/2022", 
        invoice_status_id: invoice_status.id) }

      it 'is not valid' do
        expect(invoice).to_not be_valid
      end
    end
  end

  describe 'invoice_status_id attribute' do
    context 'with invalid values' do
      let(:invoice) { described_class.new(business_name: 'Codify', business_nit: '123', number: 1, subtotal: 10, date: "12/08/2022", 
        branch_office_id: branch_office.id) }

      it 'is not valid' do
        expect(invoice).to_not be_valid
      end
    end
  end

  describe '#default_values' do
    context 'with missing values' do
      let(:invoice) { described_class.new(number: 1, branch_office_id: branch_office.id, invoice_status_id: invoice_status.id) }

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
      let(:invoice) { described_class.create!(date: "12/08/2022", business_name: 'Codify', business_nit: '123', number: 1, subtotal: 10, total: 10, 
        branch_office_id: branch_office.id, invoice_status_id: invoice_status.id) }
      let(:company) { Company.create!(name: 'Codify', nit: '123', address: 'Anywhere') }
      let(:product) { Product.create!(primary_code: 'ABC', description: 'ABC', company_id: company.id) }
      let(:measurement) { Measurement.create!(description: 'ABC') }
      
      before { InvoiceDetail.create!(description: 'ABC', unit_price: 1 , quantity: 1, subtotal: 1, discount: 0, total: 1,
        product_id: product.id, invoice_id: invoice.id, measurement_id: measurement.id) }

      it 'destroys the detail' do
        expect { invoice.destroy }.to change { InvoiceDetail.count }.by(-1)
      end
    end
  end
end
