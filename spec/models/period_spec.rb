# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Period, type: :model do
  it { is_expected.to belong_to(:cycle) }

  let(:cycle) { create(:cycle) }
  subject { build(:period, cycle: cycle) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:period) { build(:period, cycle: cycle, description: nil) }

      it 'is invalid' do
        expect(period).to_not be_valid
        period.description = ''
        expect(period).to_not be_valid
      end
    end
  end

  describe 'start_date attribute' do
    it { validate_presence_of(:start_date) }

    context 'with nil or empty value' do
      let(:period) { build(:period, cycle: cycle, start_date: nil) }

      it 'is invalid' do
        expect(period).to_not be_valid
        period.start_date = ''
        expect(period).to_not be_valid
      end
    end
  end

  describe 'status attribute' do
    it { validate_presence_of(:status) }

    context 'with nil or empty value' do
      let(:period) { build(:period, cycle: cycle, status: nil) }

      it 'is invalid' do
        expect(period).to_not be_valid
        period.status = ''
        expect(period).to_not be_valid
      end
    end
  end
end
