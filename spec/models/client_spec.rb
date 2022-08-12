require 'rails_helper'

RSpec.describe Client, type: :model do
  subject { described_class.new(name: 'Cliente01', nit: 123, company_id: company.id) }
  let(:company) { Company.create!(name: 'Codify', nit: '123', address: 'Anywhere') }
  
  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'name attribute' do
    context 'with invalid values' do
      let(:client) { described_class.new(nit: '123', company_id: company.id) }

      it 'is invalid' do
        expect(client).to_not be_valid
        client.name = ''
        expect(client).to_not be_valid
      end
    end
  end

  describe 'nit attribute' do
    context 'with invalid values' do
      let(:client) { described_class.new(name: 'Cliente01', company_id: company.id) }

      it 'is invalid' do
        expect(client).to_not be_valid
      end
    end

    context 'validates numericality of nit' do
      it { validate_numericality_of(:nit).only_integer }
  
      context 'with a numeric value' do
        let(:client) { described_class.new(name: 'Cliente01', nit: '123', company_id: company.id) }
  
        it { expect(client).to be_valid }
      end
  
      describe 'with a non-numeric value' do
        let(:client) { described_class.new(name: 'Cliente01', nit: 'ABC', company_id: company.id) }
  
        it 'is invalid' do
          expect(client).to_not be_valid
          expect(client.errors[:nit]).to eq('El NIT debe ser un valor numérico.')
        end
      end
    end
  end


end
