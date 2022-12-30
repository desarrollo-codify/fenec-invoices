# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cycle, type: :model do
  it { is_expected.to belong_to(:company) }

  let(:company) { create(:company) }
  subject { build(:cycle, company: company) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'start_date attribute' do
    it { validate_presence_of(:start_date) }

    context 'with nil or empty value' do
      let(:cycle) { build(:cycle, company: company, start_date: nil) }

      it 'is invalid' do
        expect(cycle).to_not be_valid
        cycle.start_date = ''
        expect(cycle).to_not be_valid
      end
    end
  end

  describe 'end_date attribute' do
    it { validate_presence_of(:end_date) }

    context 'with nil or empty value' do
      let(:cycle) { build(:cycle, company: company, end_date: nil) }

      it 'is invalid' do
        expect(cycle).to_not be_valid
        cycle.end_date = ''
        expect(cycle).to_not be_valid
      end
    end
  end

  describe 'status attribute' do
    it { validate_presence_of(:status) }

    context 'with nil or empty value' do
      let(:cycle) { build(:cycle, company: company, status: nil) }

      it 'is invalid' do
        expect(cycle).to_not be_valid
        cycle.status = ''
        expect(cycle).to_not be_valid
      end
    end
  end
end
