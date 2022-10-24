# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Modality, type: :model do
  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:modality) { build(:modality, description: nil) }

      it 'is invalid' do
        expect(modality).to_not be_valid
        modality.description = ''
        expect(modality).to_not be_valid
      end
    end

    context 'with special characters' do
      let(:modality) { build(:modality, description: '%^&') }

      it 'is not valid' do
        expect(modality).to_not be_valid
      end
    end

    context 'with allowed characters' do
      let(:modality) { build(:modality, description: 'áü .-_') }

      it 'is valid' do
        expect(modality).to be_valid
      end
    end
  end
end
