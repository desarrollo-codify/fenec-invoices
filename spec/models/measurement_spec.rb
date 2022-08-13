require 'rails_helper'

RSpec.describe Measurement, type: :model do
  subject { described_class.new(description: 'ABC') }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }
    
    context 'with invalid value' do
      let(:measurement) { described_class.new() }

      it 'is invalid' do
        expect(measurement).to_not be_valid
        measurement.description = ''
        expect(measurement).to_not be_valid
      end
    end
  end
end
