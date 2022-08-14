# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaymentChannel, type: :model do
  subject { build(:payment_channel) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:payment_channel) { build(:payment_channel, description: nil) }

      it 'is invalid' do
        expect(payment_channel).to_not be_valid
        payment_channel.description = ''
        expect(payment_channel).to_not be_valid
      end
    end
  end
end
