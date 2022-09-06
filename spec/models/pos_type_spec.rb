# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PosType, type: :model do
  subject { build(:pos_type) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'code attribute' do
    it { validate_presence_of(:code) }

    context 'with nil or empty value' do
      let(:pos_type) { build(:pos_type, code: nil) }

      it 'is invalid' do
        expect(pos_type).to_not be_valid
        pos_type.code = ''
        expect(pos_type).to_not be_valid
      end
    end
    context 'validates uniqueness of key' do
      context 'with duplicated value' do
        before { create(:pos_type) }

        it 'is invalid' do
          expect(subject).to_not be_valid
        end
      end

      context 'with different code' do
        before { create(:pos_type, code: 'ABCD') }

        it { expect(subject).to be_valid }
      end
    end
  end
  describe 'description attribute' do
    it { validate_presence_of(:pos_type) }

    context 'with nil or empty value' do
      let(:pos_type) { build(:pos_type, description: nil) }

      it 'is invalid' do
        expect(pos_type).to_not be_valid
        pos_type.description = ''
        expect(pos_type).to_not be_valid
      end
    end
    context 'with special characters' do
      let(:pos_type) { build(:pos_type, description: '#$%') }

      it 'is not valid' do
        expect(pos_type).to_not be_valid
      end
    end

    context 'with accents' do
      let(:pos_type) { build(:pos_type, description: 'áü') }

      it 'is valid' do
        expect(pos_type).to be_valid
      end
    end
  end
end
