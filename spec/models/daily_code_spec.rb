# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DailyCode, type: :model do
  it { is_expected.to belong_to(:branch_office) }

  let(:company) { create(:company) }
  let(:branch_office) { create(:branch_office, company: company) }
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

  describe 'end_date attribute' do
    it { validate_presence_of(:end_date) }

    context 'with nil or empty value' do
      let(:daily_code) { build(:daily_code, end_date: nil) }

      it 'is invalid' do
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

    context 'with an end date lower than the last one' do
      before { create(:daily_code, branch_office: branch_office, end_date: '2022-01-02') }
      let(:daily_code) { build(:daily_code, end_date: '2022-01-01', branch_office: branch_office) }

      it 'is invalid' do
        expect(daily_code).to_not be_valid
        expect(daily_code.errors[:end_date])
          .to eq(['No se puede registrar una fecha anterior al último registro.'])
      end
    end
  end

  describe 'current scope' do
    before(:each) do
      company = Company.create!(name: 'Abc123', nit: '123456', address: 'Av. Santa Cruz')
      branch_office = BranchOffice.create!(name: 'Sucursal 1', number: 1, city: 'Santa Cruz de la Sierra', company: company) 
      branch_office_2 = BranchOffice.create!(name: 'Sucursal 2', number: 2, city: 'Santa Cruz de la Sierra', company: company) 
      @current = DailyCode.create!(code: 'ABC123', effective_date: DateTime.now, end_date: DateTime.now + 1.hour, branch_office: branch_office)
      @not_current = DailyCode.create!(code: 'ABC123', effective_date: DateTime.now - 2.hour, end_date: DateTime.now - 1.hour, branch_office: branch_office_2)
    end

    it 'Includes cuis codes current' do
      expect(DailyCode.current).to eq(@current)
    end
    
    it 'Excludes cuis codes current' do
      expect(DailyCode.current).to_not eq(@not_current)
    end
  end

  describe 'by_date scope' do
    before(:each) do
      @date = DateTime.now + 1.hour 
      company = Company.create!(name: 'Abc4321', nit: '123456', address: 'Av. Santa Cruz')
      branch_office = BranchOffice.create!(name: 'Sucursal 1', number: 1, city: 'Santa Cruz de la Sierra', company: company) 
      branch_office_2 = BranchOffice.create!(name: 'Sucursal 2', number: 2, city: 'Santa Cruz de la Sierra', company: company) 
      @non_by_date = DailyCode.create!(code: 'ABC123', effective_date: DateTime.now - 3.hour, end_date: DateTime.now - 2.hour, branch_office: branch_office)
      @by_date = DailyCode.create!(code: 'ABC123', effective_date: DateTime.now, end_date: DateTime.now + 10.hour, branch_office: branch_office_2)
    end

    it 'Includes date in daily code' do
      expect(DailyCode.by_date(@date)).to include(@by_date)
    end
    
    it 'Excludes date in daily code' do
      expect(DailyCode.by_date(@date)).to_not include(@non_by_date)
    end
  end
end
