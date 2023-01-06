# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountingTransactionLog, type: :model do
  subject { build(:accounting_transaction_log) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'full_name attribute' do
    it { validate_presence_of(:full_name) }

    context 'with nil or empty value' do
      let(:accounting_transaction_log) { build(:accounting_transaction_log, full_name: nil) }

      it 'is invalid' do
        expect(accounting_transaction_log).to_not be_valid
        accounting_transaction_log.full_name = ''
        expect(accounting_transaction_log).to_not be_valid
      end
    end
  end

  describe 'action attribute' do
    it { validate_presence_of(:action) }

    context 'with nil or empty value' do
      let(:accounting_transaction_log) { build(:accounting_transaction_log, action: nil) }

      it 'is invalid' do
        expect(accounting_transaction_log).to_not be_valid
        accounting_transaction_log.action = ''
        expect(accounting_transaction_log).to_not be_valid
      end
    end
  end

  describe 'log_action attribute' do
    it { validate_presence_of(:log_action) }

    context 'with nil or empty value' do
      let(:accounting_transaction_log) { build(:accounting_transaction_log, log_action: nil) }

      it 'is invalid' do
        expect(accounting_transaction_log).to_not be_valid
        accounting_transaction_log.log_action = ''
        expect(accounting_transaction_log).to_not be_valid
      end
    end
  end

  describe 'accounting_transaction_id attribute' do
    it { validate_presence_of(:accounting_transaction_id) }

    context 'with nil or empty value' do
      let(:accounting_transaction_log) { build(:accounting_transaction_log, accounting_transaction_id: nil) }

      it 'is invalid' do
        expect(accounting_transaction_log).to_not be_valid
        accounting_transaction_log.accounting_transaction_id = ''
        expect(accounting_transaction_log).to_not be_valid
      end
    end
  end
end
