# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoomType, type: :model do
  subject { build(:room_type) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'code attribute' do
    it { validate_presence_of(:code) }

    context 'with nil or empty value' do
      let(:room_type) { build(:room_type, code: nil) }

      it 'is invalid' do
        expect(room_type).to_not be_valid
        room_type.code = ''
        expect(room_type).to_not be_valid
      end
    end

    context 'validates uniqueness of code' do
      context 'with duplicated value' do
        before { create(:room_type) }

        it 'is invalid when code is duplicated' do
          expect(subject).to_not be_valid
        end
      end

      context 'with different code' do
        before { create(:room_type, code: 'Codify 2') }

        it 'is valid' do
          expect(subject).to be_valid
        end
      end
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:room_type) { build(:room_type, description: nil) }

      it 'is invalid' do
        expect(room_type).to_not be_valid
        room_type.description = ''
        expect(room_type).to_not be_valid
      end
    end

    context 'with special characters' do
      let(:room_type) { build(:room_type, description: '#$%') }

      it 'is not valid' do
        expect(room_type).to_not be_valid
      end
    end
  end
end
