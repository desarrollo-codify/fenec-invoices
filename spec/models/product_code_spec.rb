# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductCode, type: :model do
  subject { build(:product_code) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'code attribute' do
    it { validate_presence_of(:code) }

    context 'with nil or empty value' do
      let(:product_code) { build(:product_code, code: nil) }

      it 'is invalid' do
        expect(product_code).to_not be_valid
        product_code.code = ''
        expect(product_code).to_not be_valid
      end
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:product_code) { build(:product_code, description: nil) }

      it 'is invalid' do
        expect(product_code).to_not be_valid
        product_code.description = ''
        expect(product_code).to_not be_valid
      end
    end

    context 'with special characters' do
      let(:product_code) { build(:product_code, description: '#$%') }

      it 'is not valid' do
        expect(product_code).to_not be_valid
      end
    end

    context 'with allowed characters' do
      let(:product_code) { build(:product_code, description: 'áü.-_ ') }

      it 'is valid' do
        expect(product_code).to be_valid
      end
    end
  end

  describe 'economic_activity_id attribute' do
    context 'not associated to a economic_activity' do
      let(:product_code) { build(:product_code, economic_activity: nil) }

      it 'is invalid' do
        expect(product_code).to_not be_valid
      end
    end
  end
end
