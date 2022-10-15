# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CuisCode, type: :model do
  it { is_expected.to belong_to(:branch_office) }

  let(:branch_office) { create(:branch_office) }
  subject { build(:cuis_code, branch_office: branch_office) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'code attribute' do
    it { validate_presence_of(:code) }

    context 'with nil or empty value' do
      let(:cuis_code) { build(:cuis_code, code: nil) }

      it 'is invalid' do
        expect(cuis_code).to_not be_valid
        cuis_code.code = ''
        expect(cuis_code).to_not be_valid
      end
    end
    context 'validates uniqueness of code' do
      context 'with duplicated value' do
        before { create(:cuis_code, branch_office: branch_office) }

        it 'is invalid' do
          expect(subject).to_not be_valid
          expect(subject.errors[:code]).to eq ['Solo puede haber un CUIS por sucursal.']
        end
      end

      context 'with different code' do
        before { create(:cuis_code, branch_office: branch_office, code: 'ABCD') }

        it { expect(subject).to be_valid }
      end
    end
  end

  describe 'expiration_date attribute' do
    it { validate_presence_of(:expiration_date) }

    context 'with nil value' do
      let(:cuis_code) { build(:cuis_code, expiration_date: nil) }

      it 'is invalid' do
        expect(cuis_code).to_not be_valid
        cuis_code.expiration_date = ''
        expect(cuis_code).to_not be_valid
      end
    end
  end

  describe 'branch_office attribute' do
    it { validate_presence_of(:branch_office) }

    context 'with nil or empty value' do
      let(:cuis_code) { build(:cuis_code, branch_office: nil) }

      it 'is invalid' do
        expect(cuis_code).to_not be_valid
      end
    end
  end
  describe '#default_values' do
    context 'with missing values' do
      let(:cuis_code) { build(:cuis_code, default_values: true, branch_office: branch_office) }

      it 'has default values' do
        expect(cuis_code.current_number).to eq(1)
      end
    end
  end

  describe 'current scope' do
    before { create(:cuis_code, branch_office: branch_office) }
    context 'with include or not cuis code current' do
      let(:not_current) { create(:cuis_code, code: 'ABC123', expiration_date: DateTime.now - 1.hour, branch_office: branch_office) }

      it 'Includes cuis codes current' do
        expect(branch_office.cuis_codes.current.code).to eq('ABC')
        expect(CuisCode.current).to_not eq(not_current)
      end
    end
  end
end
