# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'associations' do
    it { should belong_to(:taggable) }
  end

  subject { build(:tag) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:tag) { build(:tag, description: nil) }

      it 'is invalid' do
        expect(tag).to_not be_valid
        tag.description = ''
        expect(tag).to_not be_valid
      end
    end
  end

  describe 'taggable type' do
    before { create(:tag) }

    it 'when tag is associated with order' do
      tag = Tag.first
      expect(Order.first.tags.first).to eq(tag)
    end
  end
end
