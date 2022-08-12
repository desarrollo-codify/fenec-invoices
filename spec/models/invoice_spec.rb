require 'rails_helper'

RSpec.describe Invoice, type: :model do
  subject { described_class.new(date: "12/08/2022",business_name: 'Codify', business_nit: '123', number: 1, subtotal: 10, total: 10, branch_office_id: branch_office.id, invoice_status_id: invoice_status.id) }
  let(:branch_office) { BranchOffice.create!(name: 'Sucursal 1', number: 1, city: 'Santa Cruz', company_id: company.id) }
  let(:invoice_status) { InvoiceStatus.create!() }
  let(:company) { Company.create!(name: 'Codify', nit: '123', address: 'Anywhere') }

  
  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'with invalid values' do
    describe 'with no business name' do
      subject { described_class.new(date: "12/08/2022", business_name: '', business_nit: '123', number: 1, subtotal: 10, total: 10, branch_office_id: branch_office.id, invoice_status_id: invoice_status.id) }

      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end

    describe 'with no business nit' do
      subject {
        described_class.new(date: "12/08/2022", business_name: 'Codify',business_nit: '', number: 1, subtotal: 10, total: 10, branch_office_id: branch_office.id, invoice_status_id: invoice_status.id)
      }

      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end

    describe 'with no subtotal' do
      subject {
        described_class.new(date: "12/08/2022", business_name: 'Codify', business_nit: '123', number: 1, total: 10, branch_office_id: branch_office.id, invoice_status_id: invoice_status.id)
      }

      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end

    describe 'with no total' do
      subject {
        described_class.new(date: "12/08/2022", business_name: 'Codify', business_nit: '123', number: 1, subtotal: 10, branch_office_id: branch_office.id, invoice_status_id: invoice_status.id)
      }

      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end
    describe 'with no date' do
      subject {
        described_class.new(business_name: 'Codify', business_nit: '123', number: 1, subtotal: 10, branch_office_id: branch_office.id, invoice_status_id: invoice_status.id)
      }

      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end
  end

  describe 'validates uniqueness of number per invoice' do
    context 'with duplicated number' do
      before { described_class.create!(date: "12/08/2022", business_name: 'Codify', business_nit: '123', number: 1, subtotal: 10, total: 10, branch_office_id: branch_office.id, invoice_status_id: invoice_status.id) }

      it 'is invalid when number is duplicated' do
        expect(subject).to_not be_valid
      end
    end
    context 'with different number' do
      before { described_class.create!(date: "12/08/2022", business_name: 'Codify', business_nit: '123', number: 2, subtotal: 10, total: 10, branch_office_id: branch_office.id, invoice_status_id: invoice_status.id) }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end
  end

  describe 'validate numericality of business nit' do
    it { validate_numericality_of(:nit).only_integer }

    describe 'with valid value' do
      subject { described_class.new(date: "12/08/2022", business_name: 'Codify', business_nit: '123', number: 1, subtotal: 10, total: 10, branch_office_id: branch_office.id, invoice_status_id: invoice_status.id) }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    describe 'with invalid value' do
      subject { described_class.new(date: "12/08/2022", business_name: 'Codify', business_nit: 'ABC', number: 1, subtotal: 10, total: 10, branch_office_id: branch_office.id, invoice_status_id: invoice_status.id) }

      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end
  end

  describe 'validate numericality of subtotal' do
    it { validate_numericality_of(:nit).only_integer }

    describe 'with valid value' do
      subject { described_class.new(date: "12/08/2022", business_name: 'Codify', business_nit: '123', number: 1, subtotal: 10, total: 10, branch_office_id: branch_office.id, invoice_status_id: invoice_status.id) }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    describe 'with invalid value' do
      subject { described_class.new(date: "12/08/2022", business_name: 'Codify', business_nit: '123', number: 1, subtotal: 'ABC', total: 10, branch_office_id: branch_office.id, invoice_status_id: invoice_status.id) }

      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end
  end

  describe 'validate numericality of total' do
    it { validate_numericality_of(:nit).only_integer }

    describe 'with valid value' do
      subject { described_class.new(date: "12/08/2022", business_name: 'Codify', business_nit: '123', number: 1, subtotal: 10, total: 10, branch_office_id: branch_office.id, invoice_status_id: invoice_status.id) }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    describe 'with invalid value' do
      subject { described_class.new(date: "12/08/2022", business_name: 'Codify', business_nit: '123', number: 1, subtotal: 10, total: 'ABC', branch_office_id: branch_office.id, invoice_status_id: invoice_status.id) }

      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end
  end
end
