# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContingencyCode, type: :model do
  it { is_expected.to belong_to(:economic_activity) }

  let(:company) { create(:company) }
  let(:economic_activity) { create(:economic_activity, company: company) }
  subject { build(:contingency_code, default_values: true, economic_activity: economic_activity) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'code attribute' do
    it { validate_presence_of(:code) }

    context 'with nil or empty value' do
      let(:contingency_code) { build(:contingency_code, code: nil) }

      it 'is invalid' do
        expect(contingency_code).to_not be_valid
        contingency_code.code = ''
        expect(contingency_code).to_not be_valid
      end
    end
    context 'validates uniqueness of code' do
      context 'with duplicated value' do
        before { create(:contingency_code, economic_activity: economic_activity) }

        it 'is invalid' do
          expect(subject).to_not be_valid
        end
      end

      context 'with different effective_date' do
        before { create(:contingency_code, economic_activity: economic_activity, code: 'abc123') }

        it { expect(subject).to be_valid }
      end
    end
  end

  describe 'document_sector_code attribute' do
    it { validate_presence_of(:document_sector_code) }

    context 'with nil or empty value' do
      let(:contingency_code) { build(:contingency_code, default_values: true, document_sector_code: nil) }

      it 'is invalid' do
        expect(contingency_code).to_not be_valid
      end
    end

    context 'validates numericality of document_sector_code' do
      it { validate_numericality_of(:document_sector_code).only_integer }

      describe 'with a non-numeric value' do
        let(:contingency_code) { build(:contingency_code, default_values: true, document_sector_code: 'ABC') }

        it 'is invalid' do
          expect(contingency_code).to_not be_valid
          expect(contingency_code.errors[:document_sector_code]).to eq(
            ['El Codigo de documento Sector debe ser un valor numérico.']
          )
        end
      end
    end
  end

  describe 'limit attribute' do
    it { validate_presence_of(:limit) }

    context 'validates numericality of limit' do
      it { validate_numericality_of(:limit).only_integer }

      describe 'with a non-numeric value' do
        let(:contingency_code) { build(:contingency_code, default_values: true, limit: 'ABC') }

        it 'is invalid' do
          expect(contingency_code).to_not be_valid
          expect(contingency_code.errors[:limit]).to eq(['El limite debe ser un valor numérico.'])
        end
      end
    end
  end

  describe 'current_use attribute' do
    it { validate_presence_of(:current_use) }

    context 'with nil value' do
      let(:contingency_code) { build(:contingency_code, default_values: true, current_use: nil) }

      it 'is invalid' do
        expect(contingency_code).to_not be_valid
      end
    end

    context 'validates numericality of current_use' do
      it { validate_numericality_of(:current_use).only_integer }

      describe 'with a non-numeric value' do
        let(:contingency_code) { build(:contingency_code, default_values: true, current_use: 'ABC') }

        it 'is invalid' do
          expect(contingency_code).to_not be_valid
        end
      end
    end

    context 'validates limit of current_use' do
      describe 'with current_use is less' do
        let(:contingency_code) { build(:contingency_code, default_values: true, current_use: 8) }

        it 'is valid' do
          expect(contingency_code).to be_valid
        end
      end

      describe 'with current_use is higher' do
        let(:contingency_code) { build(:contingency_code, default_values: true, current_use: 11) }

        it 'is invalid' do
          expect(contingency_code).to_not be_valid
        end
      end
    end
  end

  describe 'available attribute' do
    it { validate_presence_of(:available) }
    
    before(:each) do
      @non_available = ContingencyCode.create!(code: 'abcd1234', document_sector_code: 1, limit: 10, current_use: 10, available: false, economic_activity: economic_activity)
      @available = ContingencyCode.create!(code: '1234abcd', document_sector_code: 1, limit: 10, current_use: 0, available: true, economic_activity: economic_activity)
    end

    it 'Includes contingency codes availables' do
      expect(ContingencyCode.available).to_not include(@non_available)
    end

    it 'Excludes contingency codes availables' do
      expect(ContingencyCode.available).to include(@available)
    end
  end
end
