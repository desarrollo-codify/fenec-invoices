require 'rails_helper'

RSpec.describe Company, type: :model do
  subject { described_class.new(name: 'Codify', nit: '123', address: 'Anywhere') }
  
  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'name attribute' do
    it { validate_presence_of(:name) }
    
    context 'with invalid values' do
      let(:company) { described_class.new(nit: '123', address: 'Anywhere') }

      it 'is invalid' do
        expect(company).to_not be_valid
        company.name = ''
        expect(company).to_not be_valid
      end
    end

    context 'validates uniqueness of name' do
      context 'with duplicated value' do
        before { described_class.create!(name: 'Codify', nit: '456', address: 'Santa Cruz') }
  
        it 'is invalid when name is duplicated' do
          expect(subject).to_not be_valid
        end
      end
  
      context 'with different name' do
        before { described_class.create!(name: 'Codify 2', nit: '456', address: 'Santa Cruz') }
  
        it 'is valid' do
          expect(subject).to be_valid
        end
      end
    end

    context 'with special characters' do
      let(:company) { described_class.new(name: '#$%', nit: '456', address: 'Santa Cruz') }
      
      it 'is not valid' do
        expect(company).to_not be_valid
      end
    end

    context 'with allowed characters' do
      let(:company) { described_class.new(name: 'áü.-_ ', nit: '123', address: 'Santa Cruz') }
      
      it 'is valid' do
        expect(company).to be_valid
      end
    end
  end

  describe 'nit attribute' do
    it { validate_presence_of(:nit) }
    
    context 'with invalid values' do
      let(:company) { described_class.new(name: 'Codify', address: 'Anywhere') }

      it 'is invalid' do
        expect(company).to_not be_valid
      end
    end

    context 'validates numericality of nit' do
      it { validate_numericality_of(:nit).only_integer }
  
      context 'with a numeric value' do
        let(:company) { described_class.new(name: 'Cliente01', nit: '123', address: 'Santa Cruz') }
  
        it { expect(company).to be_valid }
      end
  
      context 'with a non-numeric value' do
        let(:company) { described_class.new(name: 'Cliente01', nit: 'ABC', address: 'Santa Cruz') }
  
        it 'is invalid' do
          expect(company).to_not be_valid
          expect(company.errors[:nit]).to eq ['El NIT debe ser un valor numérico.']
        end
      end
    end
  end

  describe 'address attribute' do
    it { validate_presence_of(:address) }
    
    context 'with invalid values' do
      let(:company) { described_class.new(name: 'Codify', nit: '123') }

      it 'is invalid' do
        expect(company).to_not be_valid
        company.address = ''
        expect(company).to_not be_valid
      end
    end
  end

  describe 'validates dependent destroy for branch office' do
    it { expect(subject).to have_many(:branch_offices).dependent(:destroy) }

    context 'when deleting a company' do
      let(:company) { described_class.create!(name: 'Codify', nit: '456', address: 'Santa Cruz') }
      before { BranchOffice.create!(name: 'Sucursal 1', number: 1, city: 'Santa Cruz', company_id: company.id) }
      
      it 'destroys the branch office' do
        expect { company.destroy }.to change { BranchOffice.count }.by(-1)
      end
    end
  end

  describe 'validates dependent destroy for products' do
    it { expect(subject).to have_many(:products).dependent(:destroy) }

    describe 'when deleting a company' do
      let(:company) { described_class.create!(name: 'Codify', nit: '456', address: 'Santa Cruz') }
      before { Product.create!(primary_code: 'ABC', description: 'Algo', company_id: company.id) }
      
      it 'destroys the Product' do
        expect { company.destroy }.to change { Product.count }.by(-1)
      end
    end
  end

  describe 'validates dependent destroy for clients' do
    it { expect(subject).to have_many(:clients).dependent(:destroy) }

    context 'when deleting a company' do
      let(:company) { described_class.create!(name: 'Codify', nit: '456', address: 'Santa Cruz') }
      before { Client.create!(name: 'Juan', nit: '123', company_id: company.id) }
      
      it 'destroys the Client' do
        expect { company.destroy }.to change { Client.count }.by(-1)
      end
    end
  end
end
