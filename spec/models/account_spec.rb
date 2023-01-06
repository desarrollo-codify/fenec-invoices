# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account, type: :model do
  it { is_expected.to belong_to(:company) }
  it { is_expected.to belong_to(:cycle) }
  it { is_expected.to belong_to(:account_type) }
  it { is_expected.to belong_to(:account_level) }

  subject { build(:account) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:account) { build(:account, description: nil) }

      it 'is invalid' do
        expect(account).to_not be_valid
        account.description = ''
        expect(account).to_not be_valid
      end
    end
  end
end
