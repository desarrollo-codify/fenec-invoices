# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountLevel, type: :model do
  subject { build(:account_level) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:account_level) { build(:account_level, description: nil) }

      it 'is invalid' do
        expect(account_level).to_not be_valid
        account_level.description = ''
        expect(account_level).to_not be_valid
      end
    end
  end
end
