# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payment, type: :model do
  subject { build(:payment) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'mount attribute' do
    it { validate_presence_of(:mount) }

    context 'with nil or empty value' do
      let(:payment) { build(:payment, mount: nil) }

      it 'is invalid' do
        expect(payment).to_not be_valid
        payment.mount = ''
        expect(payment).to_not be_valid
      end
    end
  end

  describe 'invoice_id attribute' do
    context 'not associated to a invoice' do
      let(:payment) { build(:payment, invoice: nil) }

      it 'is invalid' do
        expect(payment).to_not be_valid
      end
    end
  end

  describe 'payment_method_id attribute' do
    context 'not associated to a invoice' do
      let(:payment) { build(:payment, payment_method: nil) }

      it 'is invalid' do
        expect(payment).to_not be_valid
      end
    end
  end
end
