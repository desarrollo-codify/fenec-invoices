# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DailyCode, type: :model do
  it { is_expected.to belong_to(:branch_office) }

  
  let(:company) { create(:company) }
  let(:branch_office) { create(:branch_office, company: company )}
  subject { build(:daily_code, branch_office: branch_office) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'code attribute' do
    it { validate_presence_of(:code) }

    context 'with nil or empty value' do
      let(:daily_code) { build(:daily_code, code: nil) }

      it 'is invalid' do
        expect(daily_code).to_not be_valid
        daily_code.code = ''
        expect(daily_code).to_not be_valid
      end
    end
  end

  describe 'efective_date attribute' do
    it { validate_presence_of(:effective_date) }

    context 'with nil value' do
      let(:daily_code) { build(:daily_code, effective_date: nil) }

      it 'is invalid' do
        expect(daily_code).to_not be_valid
      end
    end

    context 'validates uniqueness of effective_date' do
      context 'with duplicated value' do
        before { create(:daily_code, branch_office: branch_office) }

        it 'is invalid' do
          expect(subject).to_not be_valid
          expect(subject.errors[:effective_date]).to eq ['Solo puede ser un codigo diario por sucursal.']
        end
      end

      context 'with different effective_date' do
        before { create(:daily_code, branch_office: branch_office, effective_date: '2021-12-31') }

        it { expect(subject).to be_valid }
      end
    end

    context 'with an effective date lower than the last one' do
      before { create(:daily_code, branch_office: branch_office, effective_date: '2022-01-02') }
      let(:daily_code) { build(:daily_code, effective_date: '2022-01-01', branch_office: branch_office) }

      it 'is invalid' do
        expect(daily_code).to_not be_valid
        expect(daily_code.errors[:effective_date])
          .to eq(['No se puede registrar una fecha anterior al último registro.'])
      end
    end
  end
end
