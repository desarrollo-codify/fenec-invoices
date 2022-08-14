# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Measurement, type: :model do
  subject { build(:measurement) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:measurement) { build(:measurement, description: nil) }

      it 'is invalid' do
        expect(measurement).to_not be_valid
        measurement.description = ''
        expect(measurement).to_not be_valid
      end
    end
  end
end
