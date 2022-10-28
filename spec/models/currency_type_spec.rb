# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CurrencyType, type: :model do
  subject { build(:currency_type) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'code attribute' do
    it { validate_presence_of(:code) }

    context 'with nil or empty value' do
      let(:currency_type) { build(:currency_type, code: nil) }

      it 'is invalid' do
        expect(currency_type).to_not be_valid
        currency_type.code = ''
        expect(currency_type).to_not be_valid
      end
    end

    context 'validates uniqueness of code' do
      context 'with duplicated value' do
        before { create(:currency_type) }

        it 'is invalid' do
          expect(subject).to_not be_valid
        end
      end

      context 'with different code' do
        before { create(:currency_type, code: 'ABCD') }

        it { expect(subject).to be_valid }
      end
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:currency_type) { build(:currency_type, description: nil) }

      it 'is invalid' do
        expect(currency_type).to_not be_valid
        currency_type.description = ''
        expect(currency_type).to_not be_valid
      end
    end

    context 'with special characters' do
      let(:currency_type) { build(:currency_type, description: '%^&') }

      it 'is not valid' do
        expect(currency_type).to_not be_valid
      end
    end

    context 'with allowed characters' do
      let(:currency_type) { build(:currency_type, description: 'áü .-_') }

      it 'is valid' do
        expect(currency_type).to be_valid
      end
    end
  end
end
