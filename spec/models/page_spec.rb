# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Page, type: :model do
  it { is_expected.to belong_to(:system_module) }

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:page) { build(:page, description: nil) }

      it 'is invalid' do
        expect(page).to_not be_valid
        page.description = ''
        expect(page).to_not be_valid
      end
    end
  end
end
