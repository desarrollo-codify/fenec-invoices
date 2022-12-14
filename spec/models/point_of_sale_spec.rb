# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PointOfSale, type: :model do
  it { is_expected.to belong_to(:branch_office) }

  let(:company) { create(:company) }
  let(:branch_office) { create(:branch_office, company: company) }
  subject { build(:point_of_sale, branch_office: branch_office) }

  describe 'name attribute' do
    it { validate_presence_of(:name) }

    context 'with nil or empty value' do
      let(:point_of_sale) { build(:point_of_sale, name: nil) }

      it 'is invalid' do
        expect(point_of_sale).to_not be_valid
        point_of_sale.name = ''
        expect(point_of_sale).to_not be_valid
      end
    end

    context 'with special characters' do
      let(:point_of_sale) { build(:point_of_sale, name: '%^&') }

      it 'is not valid' do
        expect(point_of_sale).to_not be_valid
      end
    end

    context 'with allowed characters' do
      let(:point_of_sale) { build(:point_of_sale, name: 'áü .-_') }

      it 'is valid' do
        expect(point_of_sale).to be_valid
      end
    end
  end

  describe 'code attribute' do
    context 'validates uniqueness of code' do
      context 'with duplicated value' do
        it 'is invalid' do
          subject.code = 0
          expect(subject).to_not be_valid
          expect(subject.errors[:code]).to eq ['Ya existe este codigo de punto de venta para esta sucursal.']
        end
      end

      context 'with different code' do
        before { create(:point_of_sale, branch_office: branch_office, code: 456) }

        it { expect(subject).to be_valid }
      end
    end
  end
end
