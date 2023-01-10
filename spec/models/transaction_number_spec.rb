# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransactionNumber, type: :model do
  describe 'associations' do
    it { should belong_to(:period) }
    it { should belong_to(:transaction_type) }
  end

  describe 'callbacks' do
    it 'sets the default value for the number field' do
      transaction_number = create(:transaction_number)
      expect(transaction_number.number).to eq(1)
    end
  end

  describe 'methods' do
    it 'increments the number field' do
      transaction_number = create(:transaction_number)
      transaction_number.increment!
      expect(transaction_number.number).to eq(2)
    end
  end
end
