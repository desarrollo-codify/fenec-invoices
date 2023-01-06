# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductStatus, type: :model do
  subject { build(:product_status) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:product_status) { build(:product_status, description: nil) }

      it 'is invalid' do
        expect(product_status).to_not be_valid
        product_status.description = ''
        expect(product_status).to_not be_valid
      end
    end
  end
end
