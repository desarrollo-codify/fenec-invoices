# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountType, type: :model do
  subject { build(:account_type) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:account_type) { build(:account_type, description: nil) }

      it 'is invalid' do
        expect(account_type).to_not be_valid
        account_type.description = ''
        expect(account_type).to_not be_valid
      end
    end
  end
end
