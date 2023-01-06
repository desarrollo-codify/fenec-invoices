# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductType, type: :model do
  subject { build(:product_type) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:product_type) { build(:product_type, description: nil) }

      it 'is invalid' do
        expect(product_type).to_not be_valid
        product_type.description = ''
        expect(product_type).to_not be_valid
      end
    end
  end
end
