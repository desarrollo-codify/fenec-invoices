# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoiceType, type: :model do
  subject { build(:invoice_type) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'code attribute' do
    it { validate_presence_of(:code) }

    context 'with nil or empty value' do
      let(:invoice_type) { build(:invoice_type, code: nil) }

      it 'is invalid' do
        expect(invoice_type).to_not be_valid
        invoice_type.code = ''
        expect(invoice_type).to_not be_valid
      end
    end

    context 'validates uniqueness of code' do
      context 'with duplicated value' do
        before { create(:invoice_type) }

        it 'is invalid' do
          expect(subject).to_not be_valid
        end
      end

      context 'with different code' do
        before { create(:invoice_type, code: 'ABCD') }

        it { expect(subject).to be_valid }
      end
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:invoice_type) { build(:invoice_type, description: nil) }

      it 'is invalid' do
        expect(invoice_type).to_not be_valid
        invoice_type.description = ''
        expect(invoice_type).to_not be_valid
      end
    end

    context 'with special characters' do
      let(:invoice_type) { build(:invoice_type, description: '%^&') }

      it 'is not valid' do
        expect(invoice_type).to_not be_valid
      end
    end

    context 'with allowed characters' do
      let(:invoice_type) { build(:invoice_type, description: 'áü .-_') }

      it 'is valid' do
        expect(invoice_type).to be_valid
      end
    end
  end
end
