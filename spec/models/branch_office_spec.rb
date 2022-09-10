# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BranchOffice, type: :model do
  it { is_expected.to belong_to(:company) }
  it { is_expected.to have_many(:daily_codes) }
  it { is_expected.to have_many(:invoices) }
  it { is_expected.to have_many(:point_of_sales) }

  let(:company) { create(:company) }
  subject { build(:branch_office, company: company) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'name attribute' do
    it { validate_presence_of(:name) }

    context 'with nil or empty value' do
      let(:branch_office) { build(:branch_office, company: company, name: nil) }

      it 'is invalid' do
        expect(branch_office).to_not be_valid
        branch_office.name = ''
        expect(branch_office).to_not be_valid
      end
    end

    context 'with special characters' do
      let(:branch_office) { build(:branch_office, name: '$%^') }

      it 'is not valid' do
        expect(branch_office).to_not be_valid
      end
    end

    context 'with allowed characters' do
      let(:branch_office) { build(:branch_office, name: 'áú .-_') }

      it 'is valid' do
        expect(branch_office).to be_valid
      end
    end
  end

  describe 'number attribute' do
    it { validate_presence_of(:number) }

    context 'with nil value' do
      let(:branch_office) { build(:branch_office, number: nil) }

      it 'is not valid' do
        expect(branch_office).to_not be_valid
      end
    end

    context 'validates uniqueness per company' do
      context 'with duplicated number' do
        before { create(:branch_office) }
        let(:branch_office) { build(:branch_office, company_id: 1) }

        it 'is invalid when number is duplicated' do
          expect(branch_office).to_not be_valid
          expect(branch_office.errors[:number]).to eq ['el numero de sucursal no puede duplicarse en una empresa.']
        end
      end

      context 'with different number' do
        before { create(:branch_office, company: company, number: 2) }

        it 'is valid' do
          expect(subject).to be_valid
        end
      end
    end
  end

  describe 'city attribute' do
    it { validate_presence_of(:city) }

    context 'with nil or empty value' do
      let(:branch_office) { build(:branch_office, city: nil) }

      it 'is not valid' do
        expect(branch_office).to_not be_valid
        branch_office.city = ''
        expect(branch_office).to_not be_valid
      end
    end

    context 'with special characters' do
      let(:branch_office) { build(:branch_office, city: '#$%') }

      it 'is not valid' do
        expect(branch_office).to_not be_valid
      end
    end

    context 'with allowed characters' do
      let(:branch_office) { build(:branch_office, city: 'áü ') }

      it 'is valid' do
        expect(branch_office).to be_valid
      end
    end
  end

  describe 'company_id attribute' do
    context 'not associated to a company' do
      let(:branch_office) { build(:branch_office, company: nil) }

      it 'is invalid' do
        expect(branch_office).to_not be_valid
      end
    end
  end

  describe 'validates dependent destroy for daily_codes' do
    it { expect(subject).to have_many(:daily_codes).dependent(:destroy) }

    describe 'when deleting a branch office' do
      let(:branch_office) { create(:branch_office) }
      before { create(:daily_code, branch_office: branch_office) }

      it 'destroys the daily code' do
        expect { branch_office.destroy }.to change { DailyCode.count }.by(-1)
      end
    end
  end

  describe 'validates dependent destroy for cuis_code' do
    it { expect(subject).to have_many(:cuis_codes).dependent(:destroy) }

    describe 'when deleting a branch office' do
      let(:branch_office) { create(:branch_office) }
      before { create(:cuis_code, branch_office: branch_office) }

      it 'destroys the daily code' do
        expect { branch_office.destroy }.to change { CuisCode.count }.by(-1)
      end
    end
  end

  describe 'validates dependent destroy for contingencies' do
    it { expect(subject).to have_many(:contingencies).dependent(:destroy) }

    describe 'when deleting a branch office' do
      let(:branch_office) { create(:branch_office) }
      before { create(:contingency, branch_office: branch_office) }

      it 'destroys the daily code' do
        expect { branch_office.destroy }.to change { Contingency.count }.by(-1)
      end
    end
  end

  describe 'validates dependent destroy for point_of_sales' do
    it { expect(subject).to have_many(:point_of_sales).dependent(:destroy) }

    describe 'when deleting a branch office' do
      let(:branch_office) { create(:branch_office) }
      before { create(:point_of_sale, branch_office: branch_office) }

      it 'destroys the daily code' do
        expect { branch_office.destroy }.to change { PointOfSale.count }.by(-1)
      end
    end
  end
end
