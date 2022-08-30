# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contingency, type: :model do
  it { is_expected.to belong_to(:branch_office) }
  it { is_expected.to belong_to(:significative_event) }

  let(:branch_office) { create(:branch_office) }
  let(:significative_event) { create(:significative_event) }

  subject { build(:contingency, branch_office: branch_office, significative_event: significative_event) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'start date attribute' do
    it { validate_presence_of(:start_date) }

    context 'with nil or empty value' do
      let(:contingency) { build(:contingency, start_date: nil) }

      it 'is invalid' do
        expect(contingency).to_not be_valid
        contingency.start_date = ''
        expect(contingency).to_not be_valid
      end
    end
  end
end
