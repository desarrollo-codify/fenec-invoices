# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Brand, type: :model do
  subject { build(:brand) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:brand) { build(:brand, description: nil) }

      it 'is invalid' do
        expect(brand).to_not be_valid
        brand.description = ''
        expect(brand).to_not be_valid
      end
    end
  end
end
