require 'rails_helper'

RSpec.describe DailyCode, type: :model do
  subject { described_class.new(code: 'ABC', effective_date: "12/08/2022", branch_office_id: branch_office.id) }
  let(:branch_office) { BranchOffice.create!(name: 'Sucursal 1', number: 1, city: 'Santa Cruz', company_id: company.id) }
  let(:company) { Company.create!(name: 'Codify', nit: '123', address: 'Anywhere') }

  
  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'with invalid values' do
    describe 'with no code' do
      subject { described_class.new(effective_date: "12/08/2022", branch_office_id: branch_office.id) }

      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end
  end
  describe 'with invalid values' do
    describe 'with no effective date' do
      subject { described_class.new(code: 'ABC', branch_office_id: branch_office.id) }

      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end
  end
  describe 'validates uniqueness of effective_date' do
    context 'with duplicated value' do
      before { described_class.create!(code: 'ABC', effective_date: "12/08/2022", branch_office_id: branch_office.id) }

      it 'is invalid when effective_date is duplicated' do
        expect(subject).to_not be_valid
      #  expect(subject.errors[:code]).to eq ['Solo puede ser un codigo diario por sucursal.']
      end
    end

    context 'with different name' do
      before { described_class.create!(code: 'ABC', effective_date: "13/08/2022", branch_office_id: branch_office.id) }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end
  end
end
