require 'rails_helper'

RSpec.describe BranchOffice, type: :model do
  subject { described_class.new(name: 'Sucursal 1', number: 1, city: 'Santa Cruz', company_id: company.id) }
  let(:company) { Company.create!(name: 'Codify', nit: '123', address: 'Anywhere') }
  
  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'name attribute' do
    it { validate_presence_of(:name) }
    
    context 'with invalid value' do
      let(:branch_office) { described_class.new(number: 1, city: 'Santa Cruz', company_id: 1) }

      it 'is invalid' do
        expect(branch_office).to_not be_valid
        branch_office.name = ''
        expect(branch_office).to_not be_valid
      end
    end
  end

  describe 'number attribute' do
    it { validate_presence_of(:number) }
    
    context 'with invalid values' do
      let(:branch_office) { described_class.new(name: 'Codify', city: 'Santa Cruz', company_id: 1) }

      it 'is not valid' do
        expect(branch_office).to_not be_valid
      end
    end

    context 'validates uniqueness per company' do
      context 'with duplicated number' do
        before { described_class.create!(name: 'Sucursal 1', number: 1, city: 'Santa Cruz', company_id: company.id) }
  
        it 'is invalid when number is duplicated' do
          expect(subject).to_not be_valid
          expect(subject.errors[:number]).to eq ['el numero de sucursal no puede duplicarse en una empresa.']
        end
      end
  
      context 'with different number' do
        before { described_class.create!(name: 'Sucursal 1', number: 2, city: 'Santa Cruz', company_id: company.id) }
  
        it 'is valid' do
          expect(subject).to be_valid
        end
      end
  
    end
  end

  describe 'city attribute' do
    it { validate_presence_of(:city) }
    
    context 'with invalid values' do
      let(:branch_office) { described_class.new(name: 'Codify', number: 1, company_id: 1) }

      it 'is not valid' do
        expect(branch_office).to_not be_valid
        branch_office.city = ''
        expect(branch_office).to_not be_valid
      end
    end
  end

  describe 'company_id attribute' do
    context 'not associated to a company' do
      let(:branch_office) { described_class.new(name: 'Codify', number: 1, city: 'Santa Cruz') }

      it 'is invalid' do
        expect(branch_office).to_not be_valid
      end
    end
  end
  
  describe 'validates dependent destroy for daily_codes' do
    it { expect(subject).to have_many(:daily_codes).dependent(:destroy) }

    describe 'when deleting a branch office' do
      let(:branch_office) { described_class.create!(name: 'Sucursal 1', number: 1, city: 'Santa Cruz', company_id: company.id) }
      before { DailyCode.create!(code: 'ABC', effective_date: "12/08/2022" , branch_office_id: branch_office.id) }
      
      it 'destroys the daily code' do
        expect { branch_office.destroy }.to change { DailyCode.count }.by(-1)
      end
    end
  end
end
