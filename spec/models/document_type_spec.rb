# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentType, type: :model do
  subject { build(:document_type) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'code attribute' do
    it { validate_presence_of(:code) }

    context 'with nil or empty value' do
      let(:document_type) { build(:document_type, code: nil) }

      it 'is invalid' do
        expect(document_type).to_not be_valid
        document_type.code = ''
        expect(document_type).to_not be_valid
      end
    end
    context 'validates uniqueness of key' do
      context 'with duplicated value' do
        before { create(:document_type) }

        it 'is invalid' do
          expect(subject).to_not be_valid
        end
      end

      context 'with different code' do
        before { create(:document_type, code: 'ABCD') }

        it { expect(subject).to be_valid }
      end
    end
  end
  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:document_type) { build(:document_type, description: nil) }

      it 'is invalid' do
        expect(document_type).to_not be_valid
        document_type.description = ''
        expect(document_type).to_not be_valid
      end
    end
    context 'with special characters' do
      let(:document_type) { build(:document_type, description: '#$%') }

      it 'is not valid' do
        expect(document_type).to_not be_valid
      end
    end

    context 'with accents' do
      let(:document_type) { build(:document_type, description: 'áü') }

      it 'is valid' do
        expect(document_type).to be_valid
      end
    end
  end
end
