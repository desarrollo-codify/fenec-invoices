# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'default role' do
    context 'when role not defined' do
      let(:user) { described_class.new }

      it 'has default values' do
        expect(user.role).to eq('user')
      end
    end
  end
end
