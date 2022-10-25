# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceMessage, type: :model do
  subject { build(:service_message) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'code attribute' do
    it { validate_presence_of(:code) }

    context 'with nil or empty value' do
      let(:service_message) { build(:service_message, code: nil) }

      it 'is invalid' do
        expect(service_message).to_not be_valid
        service_message.code = ''
        expect(service_message).to_not be_valid
      end
    end

    context 'validates uniqueness of code' do
      context 'with duplicated value' do
        before { create(:service_message) }

        it 'is invalid when code is duplicated' do
          expect(subject).to_not be_valid
        end
      end

      context 'with different code' do
        before { create(:service_message, code: 'Codify 2') }

        it 'is valid' do
          expect(subject).to be_valid
        end
      end
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:service_message) { build(:service_message, description: nil) }

      it 'is invalid' do
        expect(service_message).to_not be_valid
        service_message.description = ''
        expect(service_message).to_not be_valid
      end
    end

    context 'with special characters' do
      let(:service_message) { build(:service_message, description: '#$%') }

      it 'is not valid' do
        expect(service_message).to_not be_valid
      end
    end
  end
end
