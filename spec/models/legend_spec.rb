# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Legend, type: :model do
  subject { build(:legend) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'code attribute' do
    it { validate_presence_of(:code) }

    context 'with nil or empty value' do
      let(:legend) { build(:legend, code: nil) }

      it 'is invalid' do
        expect(legend).to_not be_valid
        legend.code = ''
        expect(legend).to_not be_valid
      end
    end
  end
  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:legend) { build(:legend, description: nil) }

      it 'is invalid' do
        expect(legend).to_not be_valid
        legend.description = ''
        expect(legend).to_not be_valid
      end
    end
    context 'with special characters' do
      let(:legend) { build(:document_type, description: '#$%') }

      it 'is not valid' do
        expect(legend).to_not be_valid
      end
    end

    context 'with accents' do
      let(:legend) { build(:document_type, description: 'áü') }

      it 'is valid' do
        expect(legend).to be_valid
      end
    end
  end
end
