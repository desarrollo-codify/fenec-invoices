# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CancellationReason, type: :model do
  subject { build(:cancellation_reason) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'code attribute' do
    it { validate_presence_of(:code) }

    context 'with nil or empty value' do
      let(:cancellation_reason) { build(:cancellation_reason, code: nil) }

      it 'is invalid' do
        expect(cancellation_reason).to_not be_valid
        cancellation_reason.code = ''
        expect(cancellation_reason).to_not be_valid
      end
    end
    context 'validates uniqueness of key' do
      context 'with duplicated value' do
        before { create(:cancellation_reason) }

        it 'is invalid' do
          expect(subject).to_not be_valid
        end
      end

      context 'with different code' do
        before { create(:cancellation_reason, code: 'ABCD') }

        it { expect(subject).to be_valid }
      end
    end
  end
  describe 'description attribute' do
    it { validate_presence_of(:cancellation_reason) }

    context 'with nil or empty value' do
      let(:cancellation_reason) { build(:cancellation_reason, description: nil) }

      it 'is invalid' do
        expect(cancellation_reason).to_not be_valid
        cancellation_reason.description = ''
        expect(cancellation_reason).to_not be_valid
      end
    end
    context 'with special characters' do
      let(:cancellation_reason) { build(:cancellation_reason, description: '#$%') }

      it 'is not valid' do
        expect(cancellation_reason).to_not be_valid
      end
    end

    context 'with accents' do
      let(:cancellation_reason) { build(:cancellation_reason, description: 'áü') }

      it 'is valid' do
        expect(cancellation_reason).to be_valid
      end
    end
  end
end
