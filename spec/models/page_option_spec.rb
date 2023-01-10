# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PageOption, type: :model do
  it { is_expected.to belong_to(:page) }
  it { is_expected.to have_and_belong_to_many(:users) }

  describe 'code attribute' do
    it { validate_presence_of(:code) }

    context 'with nil or empty value' do
      let(:page_option) { build(:page_option, code: nil) }

      it 'is invalid' do
        expect(page_option).to_not be_valid
        page_option.code = ''
        expect(page_option).to_not be_valid
      end
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:page_option) { build(:page_option, description: nil) }

      it 'is invalid' do
        expect(page_option).to_not be_valid
        page_option.description = ''
        expect(page_option).to_not be_valid
      end
    end
  end
end
