# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Currency, type: :model do
  subject { build(:currency) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:currency) { build(:currency, description: nil) }

      it 'is invalid' do
        expect(currency).to_not be_valid
        currency.description = ''
        expect(currency).to_not be_valid
      end
    end
  end

  describe 'abbreviation attribute' do
    it { validate_presence_of(:abbreviation) }

    context 'with nil or empty value' do
      let(:currency) { build(:currency, abbreviation: nil) }

      it 'is invalid' do
        expect(currency).to_not be_valid
        currency.abbreviation = ''
        expect(currency).to_not be_valid
      end
    end
  end
end
