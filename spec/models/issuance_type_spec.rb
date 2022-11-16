# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IssuanceType, type: :model do
  subject { build(:issuance_type) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'code attribute' do
    it { validate_presence_of(:code) }

    context 'with nil or empty value' do
      let(:issuance_type) { build(:issuance_type, code: nil) }

      it 'is invalid' do
        expect(issuance_type).to_not be_valid
        issuance_type.code = ''
        expect(issuance_type).to_not be_valid
      end
    end

    context 'validates uniqueness of code' do
      context 'with duplicated value' do
        before { create(:issuance_type) }

        it 'is invalid when code is duplicated' do
          expect(subject).to_not be_valid
        end
      end

      context 'with different code' do
        before { create(:issuance_type, code: 'Codify 2') }

        it 'is valid' do
          expect(subject).to be_valid
        end
      end
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:issuance_type) { build(:issuance_type, description: nil) }

      it 'is invalid' do
        expect(issuance_type).to_not be_valid
        issuance_type.description = ''
        expect(issuance_type).to_not be_valid
      end
    end

    context 'with special characters' do
      let(:issuance_type) { build(:issuance_type, description: '#$%') }

      it 'is not valid' do
        expect(issuance_type).to_not be_valid
      end
    end

    context 'with allowed characters' do
      let(:issuance_type) { build(:issuance_type, description: 'áü.-_ ') }

      it 'is valid' do
        expect(issuance_type).to be_valid
      end
    end
  end
end
