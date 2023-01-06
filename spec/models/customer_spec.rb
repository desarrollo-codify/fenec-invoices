# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Customer, type: :model do
  it { is_expected.to belong_to(:company) }

  let(:company) { create(:company) }
  subject { build(:customer, company: company) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'name attribute' do
    it { validate_presence_of(:name) }

    context 'with nil or empty value' do
      let(:customer) { build(:customer, name: nil) }

      it 'is invalid' do
        expect(customer).to_not be_valid
        customer.name = ''
        expect(customer).to_not be_valid
      end
    end
  end

  describe 'nit attribute' do
    it { validate_presence_of(:nit) }

    context 'with nil value' do
      let(:customer) { build(:customer, nit: nil) }

      it 'is invalid' do
        expect(customer).to_not be_valid
      end
    end
  end

  describe 'email attribute' do
    context 'with format email' do
      let(:customer) { build(:customer, email: 'example.com') }

      it 'is not valid' do
        expect(customer).to_not be_valid
        customer.email = 'example@example'
        expect(customer).to_not be_valid
      end
    end
  end

  describe 'company_id attribute' do
    context 'with nil value' do
      let(:customer) { build(:customer, company: nil) }

      it 'is invalid' do
        expect(customer).to_not be_valid
      end
    end
  end
end
