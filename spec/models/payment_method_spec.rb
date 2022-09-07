# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaymentMethod, type: :model do
  subject { build(:payment_method) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'code attribute' do
    it { validate_presence_of(:code) }

    context 'with nil or empty value' do
      let(:payment_method) { build(:payment_method, code: nil) }

      it 'is invalid' do
        expect(payment_method).to_not be_valid
        payment_method.code = ''
        expect(payment_method).to_not be_valid
      end
    end

    context 'validates uniqueness of key' do
      context 'with duplicated value' do
        before { create(:payment_method) }

        it 'is invalid' do
          expect(subject).to_not be_valid
        end
      end

      context 'with different code' do
        before { create(:payment_method, code: 'ABCD') }

        it { expect(subject).to be_valid }
      end
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:payment_method) }

    context 'with nil or empty value' do
      let(:payment_method) { build(:payment_method, description: nil) }

      it 'is invalid' do
        expect(payment_method).to_not be_valid
        payment_method.description = ''
        expect(payment_method).to_not be_valid
      end
    end
    context 'with special characters' do
      let(:payment_method) { build(:payment_method, description: '#$%') }

      it 'is not valid' do
        expect(payment_method).to_not be_valid
      end
    end

    context 'with accents' do
      let(:payment_method) { build(:payment_method, description: 'áü') }

      it 'is valid' do
        expect(payment_method).to be_valid
      end
    end
  end
end
