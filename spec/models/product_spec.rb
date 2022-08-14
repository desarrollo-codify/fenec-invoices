# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:company) { Company.create!(name: 'Codify', nit: '456', address: 'Santa Cruz') }
  
  subject { build(:product, company: company) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'primary_code attribute' do
    it { validate_presence_of(:primary_code) }

    context 'with nil or empty value' do
      let(:product) { build(:product, primary_code: nil) }

      it 'is invalid' do
        expect(product).to_not be_valid
        product.primary_code = ''
        expect(product).to_not be_valid
      end
    end

    context 'validates uniqueness of primary_code' do
      context 'with duplicated primary_code' do
        before { create(:product, company: company) }

        it 'is invalid when primary_code is duplicated' do
          expect(subject).to_not be_valid
          expect(subject.errors[:primary_code]).to eq ['Ya existe este codigo primario de producto.']
        end
      end

      context 'with different primary_code' do
        before { create(:product, primary_code: 'Def', company: company) }

        it 'is valid' do
          expect(subject).to be_valid
        end
      end
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:product) { build(:product, description: nil) }

      it 'is invalid' do
        expect(product).to_not be_valid
        product.description = ''
        expect(product).to_not be_valid
      end
    end

    context 'with special characters' do
      let(:product) { build(:product, description: '%^&') }

      it 'is not valid' do
        expect(product).to_not be_valid
      end
    end

    context 'with allowed characters' do
      let(:product) { build(:product, description: 'áü .-_') }

      it 'is valid' do
        expect(product).to be_valid
      end
    end
  end

  describe 'company_id attribute' do
    context 'with nil value' do
      let(:product) { build(:product, company_id: nil) }

      it 'is invalid' do
        expect(product).to_not be_valid
      end
    end
  end
end
