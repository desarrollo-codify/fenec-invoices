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

  describe 'pending scope' do
    before(:each) do
      @not_pending = Contingency.create!(start_date: '2022-10-2T19:26:40.905', end_date: '2022-10-3T19:26:40.905' ,significative_event: significative_event, point_of_sale: point_of_sale)
      @pending = Contingency.create!(start_date: '2022-10-2T19:26:40.905', significative_event: significative_event, point_of_sale: point_of_sale)
    end

    it 'Includes only the expected contingency' do
      expect(Contingency.pending).to_not include(@not_pending)
      expect(Contingency.pending).to include(@pending)
    end
  end

  describe 'manual scope' do
    before(:each) do
      significative_event_not_manual = SignificativeEvent.create!(id:1, code:1, description: 'abc')
      significative_event_manual = SignificativeEvent.create!(id:5, code:5, description: 'abc')

      @is_manual = Contingency.create!(start_date: '2022-10-3T19:26:40.905', significative_event: significative_event_manual, point_of_sale: point_of_sale)
      @not_manual = Contingency.create!(start_date: '2022-10-2T19:26:40.905', significative_event: significative_event_not_manual, point_of_sale: point_of_sale)
    end

    it 'Includes only the expected cotingency' do
      expect(Contingency.manual).to include(@is_manual)
      expect(Contingency.manual).to_not include(@not_manual)
    end
  end

  describe 'automatic scope' do
    before(:each) do
      significative_event_not_automatic = SignificativeEvent.create!(id:5, code:5, description: 'abc')
      significative_event_automatic = SignificativeEvent.create!(id:1, code:1, description: 'abc')

      @is_automatic = Contingency.create!(start_date: '2022-10-3T19:26:40.905', significative_event: significative_event_automatic, point_of_sale: point_of_sale)
      @not_automatic = Contingency.create!(start_date: '2022-10-2T19:26:40.905', significative_event: significative_event_not_automatic, point_of_sale: point_of_sale)
    end

    it 'Includes only the expected cotingency' do
      expect(Contingency.automatic).to_not include(@not_automatic)
      expect(Contingency.automatic).to include(@is_automatic)
    end
  end
end
