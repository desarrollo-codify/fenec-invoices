require 'rails_helper'

RSpec.describe PageSize, type: :model do
  subject { create(:page_size) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil or empty value' do
      let(:page_size) { build(:page_size, description: nil) }

      it 'is invalid' do
        expect(page_size).to_not be_valid
        page_size.description = ''
        expect(page_size).to_not be_valid
      end
    end
  end
end
