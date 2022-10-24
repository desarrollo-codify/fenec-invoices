# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EnvironmentType, type: :model do
  subject { build(:environment_type) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:environment_type) { build(:environment_type, description: nil) }

      it 'is invalid' do
        expect(environment_type).to_not be_valid
        environment_type.description = ''
        expect(environment_type).to_not be_valid
      end
    end

    context 'with special characters' do
      let(:environment_type) { build(:environment_type, description: '%^&') }

      it 'is not valid' do
        expect(environment_type).to_not be_valid
      end
    end

    context 'with allowed characters' do
      let(:environment_type) { build(:environment_type, description: 'áü .-_') }

      it 'is valid' do
        expect(environment_type).to be_valid
      end
    end
  end
end
