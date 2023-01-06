# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Variant, type: :model do
  it { should belong_to(:product) }

  subject { build(:variant) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'title attribute' do
    it { validate_presence_of(:title) }

    context 'with nil or empty value' do
      let(:variant) { build(:variant, title: nil) }

      it 'is invalid' do
        expect(variant).to_not be_valid
        variant.title = ''
        expect(variant).to_not be_valid
      end
    end
  end
end
