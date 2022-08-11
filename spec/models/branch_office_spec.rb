require 'rails_helper'

RSpec.describe BranchOffice, type: :model do
  subject { described_class.new(name: 'Sucursal 1', number: 1, city: 'Santa Cruz', company_id: company.id) }
  let(:company) { Company.create!(name: 'Codify', nit: '123', address: 'Anywhere') }
  
  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'with invalid values' do
    describe 'with no name' do
      subject { described_class.new(name: '', number: 1, city: 'Santa Cruz', company_id: 1) }

      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end

    describe 'with no number' do
      subject {
        described_class.new(name: 'Codify', city: 'Santa Cruz', company_id: 1)
      }

      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end

    describe 'with no city' do
      subject {
        described_class.new(name: 'Codify', number: 1, company_id: 1)
      }

      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end

    describe 'not associated to a company' do
      subject { described_class.new(name: 'Codify', number: 1, city: 'Santa Cruz') }

      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end
  end

  describe 'validates uniqueness of number per company' do
    context 'with duplicated number' do
      before { described_class.create!(name: 'Sucursal 1', number: 1, city: 'Santa Cruz', company_id: company.id) }

      it 'is invalid when number is duplicated' do
        expect(subject).to_not be_valid
      end
    end

    context 'with different number' do
      before { described_class.create!(name: 'Sucursal 1', number: 2, city: 'Santa Cruz', company_id: company.id) }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end
  end
end
