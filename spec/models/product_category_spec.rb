# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductCategory, type: :model do
  subject { build(:product_category) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:product_category) { build(:product_category, description: nil) }

      it 'is invalid' do
        expect(product_category).to_not be_valid
        product_category.description = ''
        expect(product_category).to_not be_valid
      end
    end
  end
end
