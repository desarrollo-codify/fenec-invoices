# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SystemModule, type: :model do
  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:system_module) { build(:system_module, description: nil) }

      it 'is invalid' do
        expect(system_module).to_not be_valid
        system_module.description = ''
        expect(system_module).to_not be_valid
      end
    end
  end
end
