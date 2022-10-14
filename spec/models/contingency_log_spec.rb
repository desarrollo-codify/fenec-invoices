# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContingencyLog, type: :model do
  describe 'contingency_id attribute' do
    context 'with nil value' do
      let(:contingency_log) { build(:contingency_log, contingency: nil) }

      it 'is invalid' do
        expect(contingency_log).to_not be_valid
      end
    end
  end
end
