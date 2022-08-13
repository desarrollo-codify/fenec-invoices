# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaymentChannel, type: :model do
  subject { described_class.new(description: 'ABC') }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with invalid value' do
      let(:payment_channel) { described_class.new }

      it 'is invalid' do
        expect(payment_channel).to_not be_valid
        payment_channel.description = ''
        expect(payment_channel).to_not be_valid
      end
    end
  end
end
