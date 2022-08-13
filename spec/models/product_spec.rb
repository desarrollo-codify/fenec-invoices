require 'rails_helper'

RSpec.describe Product, type: :model do
  subject { described_class.new(primary_code: 'ABC', description: 'Abc', company_id: company.id) }
  let(:company) { Company.create!(name: 'Codify', nit: '456', address: 'Santa Cruz') }
  
  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'primary_code attribute' do
    it { validate_presence_of(:primary_code) }
    
    context 'with invalid value' do
      let(:product) { described_class.new(description: 'Code', company_id: company.id) }

      it 'is invalid' do
        expect(product).to_not be_valid
        product.primary_code = ''
        expect(product).to_not be_valid
      end
    end

    context 'validates uniqueness of primary_code' do
      context 'with duplicated primary_code' do
        before { described_class.create!(primary_code: 'ABC', description: 'Other', company_id: company.id) }
  
        it 'is invalid when primary_code is duplicated' do
          expect(subject).to_not be_valid
          expect(subject.errors[:primary_code]).to eq ['Ya existe este codigo primario de producto.']
        end
      end

      context 'with different primary_code' do
        before { described_class.create!(primary_code: 'DEF', description: 'Other', company_id: company.id) }
  
        it 'is valid' do
          expect(subject).to be_valid
        end
      end
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }
    
    context 'with invalid value' do
      let(:product) { described_class.new(primary_code: 'ABC', company_id: company.id) }

      it 'is invalid' do
        expect(product).to_not be_valid
        product.description = ''
        expect(product).to_not be_valid
      end
    end

    context 'with special characters' do
      let(:product) { described_class.new(primary_code: 'ABC', description: '%^&', company_id: company.id) }
      
      it 'is not valid' do
        expect(product).to_not be_valid
      end
    end

    context 'with allowed characters' do
      let(:product) { described_class.new(primary_code: 'ABC', description: 'áü .-_', company_id: company.id) }
      
      it 'is valid' do
        expect(product).to be_valid
      end
    end
  end

  describe 'company_id attribute' do
    context 'with invalid value' do
      let(:product) { described_class.new(primary_code: 'ABC', description: 'Code') }

      it 'is invalid' do
        expect(product).to_not be_valid
      end
    end
  end
end
