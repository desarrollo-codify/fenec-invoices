require 'rails_helper'

RSpec.describe InvoiceStatus, type: :model do
  subject { described_class.create!(description: 'ABC') }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'description attribute' do
    context 'with invalid value' do
      let(:invoice_status) { described_class.new() }

      it 'is invalid' do
        expect(invoice_status).to_not be_valid
        invoice_status.description = ''
        expect(invoice_status).to_not be_valid
      end
    end
  end
end
