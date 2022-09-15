# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contingency, type: :model do
  it { is_expected.to belong_to(:point_of_sale) }
  it { is_expected.to belong_to(:significative_event) }

  let(:point_of_sale) { create(:point_of_sale) }
  let(:significative_event) { create(:significative_event) }

  subject { build(:contingency, point_of_sale: point_of_sale, significative_event: significative_event) }

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
  describe 'point_of_sale_id attribute' do
    context 'with nil value' do
      let(:contingency) { build(:contingency, point_of_sale_id: nil) }

      it 'is invalid' do
        expect(contingency).to_not be_valid
      end
    end
  end
  describe 'significative_event_id attribute' do
    context 'with nil value' do
      let(:contingency) { build(:contingency, significative_event_id: nil) }

      it 'is invalid' do
        expect(contingency).to_not be_valid
      end
    end
  end
end
