# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoiceLog, type: :model do
  describe 'invoice_id attribute' do
    context 'with nil value' do
      let(:invoice_log) { build(:invoice_log, invoice: nil) }

      it 'is invalid' do
        expect(invoice_log).to_not be_valid
      end
    end
  end
end
