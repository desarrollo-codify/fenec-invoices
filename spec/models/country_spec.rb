# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Country, type: :model do
  subject { build(:country) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'code attribute' do
    it { validate_presence_of(:code) }

    context 'with nil or empty value' do
      let(:country) { build(:country, code: nil) }

      it 'is invalid' do
        expect(country).to_not be_valid
        country.code = ''
        expect(country).to_not be_valid
      end
    end

    context 'validates uniqueness of code' do
      context 'with duplicated value' do
        before { create(:country) }

        it 'is invalid' do
          expect(subject).to_not be_valid
        end
      end

      context 'with different code' do
        before { create(:country, code: 'ABCD') }

        it { expect(subject).to be_valid }
      end
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:country) { build(:country, description: nil) }

      it 'is invalid' do
        expect(country).to_not be_valid
        country.description = ''
        expect(country).to_not be_valid
      end
    end

    context 'with special characters' do
      let(:country) { build(:country, description: '%^&') }

      it 'is not valid' do
        expect(country).to_not be_valid
      end
    end

    context 'with allowed characters' do
      let(:country) { build(:country, description: 'áü .-_') }

      it 'is valid' do
        expect(country).to be_valid
      end
    end
  end
end
