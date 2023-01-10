# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Entry, type: :model do
  describe 'associations' do
    it { should belong_to(:accounting_transaction) }
    it { should belong_to(:account) }
  end
  let(:company) { create(:company) }
  let(:cycle) { create(:cycle, company: company) }
  let(:period) { create(:period, cycle: cycle) }
  let(:accounting_transaction) { build(:accounting_transaction, company: company, period: period) }
  let(:account) { create(:account, company: company, cycle: cycle) }

  subject { build(:entry, accounting_transaction: accounting_transaction, account: account) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'accounting_transaction_id attribute' do
    it { validate_presence_of(:accounting_transaction_id) }

    context 'with nil value' do
      let(:entry) { build(:entry, accounting_transaction_id: nil) }

      it 'is invalid' do
        expect(entry).to_not be_valid
      end
    end
  end

  describe '#default_values' do
    context 'with missing values' do
      let(:entry) { build(:entry) }

      it 'has default values' do
        expect(entry.debit_bs).to eq(0)
        expect(entry.credit_bs).to eq(0)
        expect(entry.debit_sus).to eq(0)
        expect(entry.credit_sus).to eq(0)
      end
    end
  end
end
