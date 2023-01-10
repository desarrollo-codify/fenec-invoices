# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountingTransaction, type: :model do
  it { is_expected.to belong_to(:currency) }
  it { is_expected.to belong_to(:period) }
  it { is_expected.to belong_to(:company) }
  it { is_expected.to belong_to(:transaction_type) }
  it { is_expected.to have_many(:entries) }

  let(:company) { create(:company) }
  let(:currency) { create(:currency) }
  let(:cycle) { create(:cycle, company: company) }
  let(:period) { create(:period, cycle: cycle) }
  let(:transaction_type) { create(:transaction_type) }
  subject { build(:accounting_transaction, company: company, currency: currency, period: period, transaction_type: transaction_type) }
  let(:account_type) { create(:account_type) }
  let(:account_level) { create(:account_level) }
  let(:account) { create(:account, account_type: account_type, account_level: account_level, company: company, cycle: cycle) }
  let(:accounting_transaction) do
    build(:accounting_transaction, company: company, currency: currency, period: period, transaction_type: transaction_type)
  end

  describe 'with valid and invalid values' do
    it 'is not valid' do
      expect(subject).to_not be_valid
    end

    it 'is valid' do
      accounting_transaction.entries.build(debit_bs: 10, account: account)
      accounting_transaction.entries.build(credit_bs: 10, account: account)
      expect(accounting_transaction).to be_valid
    end

    it 'is not valid for entries' do
      accounting_transaction.entries.build(debit_bs: 10, account: account)
      accounting_transaction.entries.build(credit_bs: 9, account: account)
      expect(accounting_transaction).to_not be_valid
    end
  end

  describe 'date attribute' do
    it { validate_presence_of(:date) }

    context 'with nil or empty value' do
      let(:accounting_transaction) do
        build(:accounting_transaction, date: nil, company: company, currency: currency, period: period,
                                       transaction_type: transaction_type)
      end

      it 'is invalid' do
        accounting_transaction.entries.build(debit_bs: 10, account: account)
        accounting_transaction.entries.build(credit_bs: 10, account: account)
        expect(accounting_transaction).to_not be_valid
        accounting_transaction.date = ''
        expect(accounting_transaction).to_not be_valid
      end
    end
  end

  describe 'gloss attribute' do
    it { validate_presence_of(:gloss) }

    context 'with nil or empty value' do
      let(:accounting_transaction) do
        build(:accounting_transaction, gloss: nil, company: company, currency: currency, period: period,
                                       transaction_type: transaction_type)
      end

      it 'is invalid' do
        accounting_transaction.entries.build(debit_bs: 10, account: account)
        accounting_transaction.entries.build(credit_bs: 10, account: account)
        expect(accounting_transaction).to_not be_valid
        accounting_transaction.gloss = ''
        expect(accounting_transaction).to_not be_valid
      end
    end
  end

  describe 'status attribute' do
    it { validate_presence_of(:status) }

    context 'with nil or empty value' do
      let(:accounting_transaction) do
        build(:accounting_transaction, status: nil, company: company, currency: currency, period: period,
                                       transaction_type: transaction_type)
      end

      it 'is invalid' do
        accounting_transaction.entries.build(debit_bs: 10, account: account)
        accounting_transaction.entries.build(credit_bs: 10, account: account)
        expect(accounting_transaction).to_not be_valid
        accounting_transaction.status = ''
        expect(accounting_transaction).to_not be_valid
      end
    end
  end
end
