# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentSector, type: :model do
  subject { build(:document_sector) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'code attribute' do
    it { validate_presence_of(:code) }

    context 'with nil or empty value' do
      let(:document_sector) { build(:document_sector, code: nil) }

      it 'is invalid' do
        expect(document_sector).to_not be_valid
        document_sector.code = ''
        expect(document_sector).to_not be_valid
      end
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:document_sector) { build(:document_sector, description: nil) }

      it 'is invalid' do
        expect(document_sector).to_not be_valid
        document_sector.description = ''
        expect(document_sector).to_not be_valid
      end
    end
  end
end
