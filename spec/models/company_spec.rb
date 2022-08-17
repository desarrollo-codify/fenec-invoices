# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Company, type: :model do
  it { is_expected.to have_many(:clients) }
  it { is_expected.to have_many(:products) }
  it { is_expected.to have_many(:branch_offices) }
  it { is_expected.to have_many(:delegated_tokens) }
  it { is_expected.to have_many(:invoices).through(:branch_offices) }

  subject { build(:company) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'name attribute' do
    it { validate_presence_of(:name) }

    context 'with nil or empty value' do
      let(:company) { build(:company, name: nil) }

      it 'is invalid' do
        expect(company).to_not be_valid
        company.name = ''
        expect(company).to_not be_valid
      end
    end

    context 'validates uniqueness of name' do
      context 'with duplicated value' do
        before { create(:company) }

        it 'is invalid when name is duplicated' do
          expect(subject).to_not be_valid
        end
      end

      context 'with different name' do
        before { create(:company, name: 'Codify 2') }

        it 'is valid' do
          expect(subject).to be_valid
        end
      end
    end

    context 'with special characters' do
      let(:company) { build(:company, name: '#$%') }

      it 'is not valid' do
        expect(company).to_not be_valid
      end
    end

    context 'with allowed characters' do
      let(:company) { build(:company, name: 'áü.-_ ') }

      it 'is valid' do
        expect(company).to be_valid
      end
    end
  end

  describe 'nit attribute' do
    it { validate_presence_of(:nit) }

    context 'with nil value' do
      let(:company) { build(:company, nit: nil) }

      it 'is invalid' do
        expect(company).to_not be_valid
      end
    end

    context 'validates numericality of nit' do
      it { validate_numericality_of(:nit).only_integer }

      context 'with a non-numeric value' do
        let(:company) { build(:company, nit: 'ABC') }

        it 'is invalid' do
          expect(company).to_not be_valid
          expect(company.errors[:nit]).to eq ['El NIT debe ser un valor numérico.']
        end
      end
    end
  end

  describe 'address attribute' do
    it { validate_presence_of(:address) }

    context 'with nil or empty value' do
      let(:company) { build(:company, address: nil) }

      it 'is invalid' do
        expect(company).to_not be_valid
        company.address = ''
        expect(company).to_not be_valid
      end
    end
  end

  describe 'validates dependent destroy for branch office' do
    it { expect(subject).to have_many(:branch_offices).dependent(:destroy) }

    context 'when deleting a company' do
      let(:company) { create(:company) }
      before { create(:branch_office, company: company) }

      it 'destroys the branch office' do
        expect { company.destroy }.to change { BranchOffice.count }.by(-1)
      end
    end
  end

  describe 'validates dependent destroy for products' do
    it { expect(subject).to have_many(:products).dependent(:destroy) }

    describe 'when deleting a company' do
      let(:company) { create(:company) }
      before { create(:product, company: company) }

      it 'destroys the Product' do
        expect { company.destroy }.to change { Product.count }.by(-1)
      end
    end
  end

  describe 'validates dependent destroy for clients' do
    it { expect(subject).to have_many(:clients).dependent(:destroy) }

    context 'when deleting a company' do
      let(:company) { create(:company) }
      before { create(:client, company: company) }

      it 'destroys the Client' do
        expect { company.destroy }.to change { Client.count }.by(-1)
      end
    end
  end

  describe 'validates dependent destroy for delegated_tokens' do
    it { expect(subject).to have_many(:delegated_tokens).dependent(:destroy) }

    context 'when deleting a company' do
      let(:company) { create(:company) }
      before { create(:delegated_token, company: company) }

      it 'destroys the Client' do
        expect { company.destroy }.to change { DelegatedToken.count }.by(-1)
      end
    end
  end
end
