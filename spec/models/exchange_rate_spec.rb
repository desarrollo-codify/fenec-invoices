# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExchangeRate, type: :model do
  subject { build(:exchange_rate) }
  let(:company) { create(:company) }

  it { is_expected.to belong_to(:company) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'date attribute' do
    it { validate_presence_of(:date) }

    context 'with nil or empty value' do
      let(:exchange_rate) { build(:exchange_rate, date: nil) }

      it 'is invalid' do
        expect(exchange_rate).to_not be_valid
      end
    end

    context 'validates uniqueness per company' do
      context 'with duplicated date' do
        before { create(:exchange_rate) }
        let(:exchange_rate) { build(:exchange_rate) }

        it 'is invalid' do
          exchange_rate.company_id = Company.first.id
          expect(exchange_rate).to_not be_valid
          expect(exchange_rate.errors[:date]).to eq ['Solo puede haber un tipo de cambio por fecha.']
        end
      end

      context 'with different number' do
        before { create(:exchange_rate, company: company, date: '2022-01-02') }

        it 'is valid' do
          expect(subject).to be_valid
        end
      end
    end
  end

  describe 'rate attribute' do
    it { validate_presence_of(:rate) }

    context 'with nil value' do
      let(:exchange_rate) { build(:exchange_rate, rate: nil) }

      it 'it is not valid' do
        expect(exchange_rate).not_to be_valid
      end
    end

    context 'validates numericality' do
      it { validate_numericality_of(:rate).is_greater_than(0) }

      context 'with non-numeric value' do
        let(:exchange_rate) { build(:exchange_rate, rate: 'A') }

        it 'is invalid' do
          expect(exchange_rate).to_not be_valid
          exchange_rate.rate = 0
          expect(exchange_rate.errors[:rate]).to eq(['Tipo de Cambio debe ser mayor a 0.'])
        end
      end
    end
  end
end
