require 'rails_helper'

RSpec.describe Client, type: :model do
  subject { described_class.new(name: 'Cliente01', nit: 123, company_id: company.id) }
  let(:company) { Company.create!(name: 'Codify', nit: '123', address: 'Anywhere') }
  
  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'with invalid values' do
    describe 'with no name' do
      subject { described_class.new(nit: '123', company_id: company.id) }

      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end
  end

  describe 'with invalid values' do
    describe 'with no nit' do
      subject { described_class.new(name: 'Cliente01', company_id: company.id) }

      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end
  end

  describe 'validate numericality of nit' do
    it { validate_numericality_of(:nit).only_integer }

    describe 'with valid value' do
      subject { described_class.new(name: 'Cliente01', nit: '123', company_id: company.id) }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    describe 'with invalid value' do
      subject { described_class.new(name: 'Cliente01', nit: 'ABC', company_id: company.id) }

      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end
  end
end
