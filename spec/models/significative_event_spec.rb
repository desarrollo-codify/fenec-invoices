# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SignificativeEvent, type: :model do
  subject { build(:significative_event) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'code attribute' do
    it { validate_presence_of(:code) }

    context 'with nil or empty value' do
      let(:significative_event) { build(:significative_event, code: nil) }

      it 'is invalid' do
        expect(significative_event).to_not be_valid
        significative_event.code = ''
        expect(significative_event).to_not be_valid
      end
    end
    context 'validates uniqueness of key' do
      context 'with duplicated value' do
        before { create(:significative_event) }

        it 'is invalid' do
          expect(subject).to_not be_valid
        end
      end

      context 'with different code' do
        before { create(:significative_event, code: 'ABCD') }

        it { expect(subject).to be_valid }
      end
    end
  end
  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:significative_event) { build(:significative_event, description: nil) }

      it 'is invalid' do
        expect(significative_event).to_not be_valid
        significative_event.description = ''
        expect(significative_event).to_not be_valid
      end
    end
    context 'with special characters' do
      let(:significative_event) { build(:significative_event, description: '#$%') }

      it 'is not valid' do
        expect(significative_event).to_not be_valid
      end
    end

    context 'with accents' do
      let(:significative_event) { build(:significative_event, description: 'áü') }

      it 'is valid' do
        expect(significative_event).to be_valid
      end
    end
  end
end
