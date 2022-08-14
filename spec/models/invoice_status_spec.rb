# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoiceStatus, type: :model do
  subject { create(:invoice_status) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:invoice_status) { build(:invoice_status, description: nil) }

      it 'is invalid' do
        expect(invoice_status).to_not be_valid
        invoice_status.description = ''
        expect(invoice_status).to_not be_valid
      end
    end
  end
end
