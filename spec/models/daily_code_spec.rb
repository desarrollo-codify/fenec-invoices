# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DailyCode, type: :model do
  subject { described_class.new(code: 'ABC', effective_date: '2022-01-01', branch_office_id: branch_office.id) }
  let(:branch_office) do
    BranchOffice.create!(name: 'Sucursal 1', number: 1, city: 'Santa Cruz', company_id: company.id)
  end
  let(:company) { Company.create!(name: 'Codify', nit: '123', address: 'Anywhere') }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'code attribute' do
    it { validate_presence_of(:code) }

    context 'with invalid values' do
      let(:daily_code) { described_class.new(effective_date: '2022-01-01', branch_office_id: branch_office.id) }

      it 'is invalid' do
        expect(daily_code).to_not be_valid
        daily_code.code = ''
        expect(daily_code).to_not be_valid
      end
    end
  end

  describe 'efective_date attribute' do
    it { validate_presence_of(:efective_date) }

    context 'with invalid values' do
      let(:daily_code) { described_class.new(code: 'ABC', branch_office_id: branch_office.id) }

      it 'is invalid' do
        expect(daily_code).to_not be_valid
      end
    end

    context 'validates uniqueness of effective_date' do
      context 'with duplicated value' do
        before do
          described_class.create!(code: 'ABC', effective_date: '2022-01-01', branch_office_id: branch_office.id)
        end

        it 'is invalid' do
          expect(subject).to_not be_valid
          expect(subject.errors[:effective_date]).to eq ['Solo puede ser un codigo diario por sucursal.']
        end
      end

      context 'with different effective_date' do
        before do
          described_class.create!(code: 'ABC', effective_date: '2021-12-31', branch_office_id: branch_office.id)
        end

        it { expect(subject).to be_valid }
      end
    end

    context 'with an effective date lower than the last one' do
      before { described_class.create!(code: 'ABC', effective_date: '2022-01-02', branch_office_id: branch_office.id) }
      let(:daily_code) do
        described_class.new(code: 'ABC', effective_date: '2022-01-01', branch_office_id: branch_office.id)
      end

      it 'is invalid' do
        expect(daily_code).to_not be_valid
        expect(daily_code.errors[:effective_date])
          .to eq(['No se puede registrar una fecha anterior al último registro.'])
      end
    end
  end
end
