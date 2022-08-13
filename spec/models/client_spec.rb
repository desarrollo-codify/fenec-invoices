# frozen_string_literal: true

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
    it { validate_presence_of(:name) }

    context 'with invalid values' do
      let(:client) { described_class.new(nit: '123', company_id: company.id) }

      it 'is invalid' do
        expect(client).to_not be_valid
        client.name = ''
        expect(client).to_not be_valid
      end
    end

    context 'with special characters' do
      let(:client) { described_class.new(name: '#$%', nit: '123', company_id: company.id) }

      it 'is not valid' do
        expect(client).to_not be_valid
      end
    end

    context 'with accents' do
      let(:client) { described_class.new(name: 'áü', nit: '123', company_id: company.id) }

      it 'is valid' do
        expect(client).to be_valid
      end
    end
  end

  describe 'nit attribute' do
    it { validate_presence_of(:nit) }

    context 'with invalid values' do
      let(:client) { described_class.new(name: 'Cliente01', company_id: company.id) }

      it 'is invalid' do
        expect(client).to_not be_valid
      end
    end

    context 'validates numericality of nit' do
      it { validate_numericality_of(:nit).only_integer }

      context 'with a numeric value' do
        let(:client) { described_class.new(name: 'Juan', nit: '123', company_id: company.id) }

        it { expect(client).to be_valid }
      end

      describe 'with a non-numeric value' do
        let(:client) { described_class.new(name: 'Juan', nit: 'ABC', company_id: company.id) }

        it 'is invalid' do
          expect(client).to_not be_valid
          expect(client.errors[:nit]).to eq(['El NIT debe ser un valor numérico.'])
        end
      end
    end
  end

  describe 'company_id attribute' do
    context 'with invalid values' do
      let(:client) { described_class.new(nit: '123', name: 'Juan') }

      it 'is invalid' do
        expect(client).to_not be_valid
      end
    end
  end
end
