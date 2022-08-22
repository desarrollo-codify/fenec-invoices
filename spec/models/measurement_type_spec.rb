require 'rails_helper'

RSpec.describe MeasurementType, type: :model do
  subject { build(:measurement_type) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'code attribute' do
    it { validate_presence_of(:code) }

    context 'with nil or empty value' do
      let(:measurement_type) { build(:measurement_type, code: nil) }

      it 'is invalid' do
        expect(measurement_type).to_not be_valid
        measurement_type.code = ''
        expect(measurement_type).to_not be_valid
      end
    end
  end
  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:measurement_type) { build(:measurement_type, description: nil) }

      it 'is invalid' do
        expect(measurement_type).to_not be_valid
        measurement_type.description = ''
        expect(measurement_type).to_not be_valid
      end
    end
    context 'with special characters' do
      let(:measurement_type) { build(:measurement_type, description: '#$%') }

      it 'is not valid' do
        expect(measurement_type).to_not be_valid
      end
    end

    context 'with accents' do
      let(:measurement_type) { build(:measurement_type, description: 'áü') }

      it 'is valid' do
        expect(measurement_type).to be_valid
      end
    end
  end
end
