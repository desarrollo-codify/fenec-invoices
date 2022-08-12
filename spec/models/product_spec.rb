require 'rails_helper'

RSpec.describe Product, type: :model do
  subject { described_class.new(primary_code: 'ABC', description: 'description for prodruct', company_id: company.id) }
  let(:company) { Company.create!(name: 'Codify', nit: '456', address: 'Santa Cruz') }
  
  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'with invalid values' do
    describe 'with no primary code' do
      subject { described_class.new(description: 'description for prodruct', company_id: company.id) }

      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end

    describe 'with no description' do
      subject {
        described_class.new(primary_code: 'ABC', company_id: company.id)
      }

      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end
  end
  describe 'validates uniqueness of primary code' do
    context 'with duplicated primary code' do
      before { described_class.create!(primary_code: 'ABC', description: 'description for prodruct', company_id: company.id) }

      it 'is invalid when primary code is duplicated' do
        expect(subject).to_not be_valid
      end
    end

    context 'with different number' do
      before { described_class.create!(primary_code: 'ABCD', description: 'description for prodruct', company_id: company.id) }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end
  end
end
