# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransactionType, type: :model do
  it { should have_many(:transaction_numbers).dependent(:destroy) }

  subject { build(:transaction_type) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:transaction_type) { build(:transaction_type, description: nil) }

      it 'is invalid' do
        expect(transaction_type).to_not be_valid
        transaction_type.description = ''
        expect(transaction_type).to_not be_valid
      end
    end
  end
end
