# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EconomicActivity, type: :model do
  it { is_expected.to belong_to(:company) }

  let(:company) { create(:company) }
  subject { build(:economic_activity, company: company) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'code attribute' do
    it { validate_presence_of(:code) }

    context 'with nil or empty value' do
      let(:economic_activity) { build(:economic_activity, code: nil) }

      it 'is invalid' do
        expect(economic_activity).to_not be_valid
        economic_activity.code = ''
        expect(economic_activity).to_not be_valid
      end
    end
  end

  describe 'description attribute' do
    it { validate_presence_of(:description) }

    context 'with nil value' do
      let(:economic_activity) { build(:economic_activity, description: nil) }

      it 'is invalid' do
        expect(economic_activity).to_not be_valid
      end
    end

    context 'with special characters' do
      let(:economic_activity) { build(:economic_activity, description: '#$%') }

      it 'is not valid' do
        expect(economic_activity).to_not be_valid
      end
    end

    context 'with accents' do
      let(:economic_activity) { build(:economic_activity, description: 'áü') }

      it 'is valid' do
        expect(economic_activity).to be_valid
      end
    end
  end

  describe 'company_id attribute' do
    context 'with nil value' do
      let(:economic_activity) { build(:economic_activity, company: nil) }

      it 'is invalid' do
        expect(economic_activity).to_not be_valid
      end
    end
  end

  describe '#random_legend' do
    let(:economic_activity) { create(:economic_activity, company: company) }

    context 'with associated legends' do
      before { create(:legend, economic_activity: economic_activity) }
      before { create(:legend, economic_activity: economic_activity, description: 'another') }

      it 'returns a ramdon legend' do
        expect(economic_activity.random_legend).to be_present
      end
    end

    context 'with no associated legends' do
      it 'returns an empty string' do
        expect(economic_activity.random_legend).to be_nil
      end
    end
  end

  describe 'validates dependent destroy of legends' do
    it { expect(subject).to have_many(:legends).dependent(:destroy) }

    context 'when deleting an economic activity' do
      let(:company) { Company.create!(name: 'Codify', nit: '123', address: 'Anywhere') }
      let(:economic_activity) { build(:economic_activity, company: company) }

      before { create(:legend, economic_activity: economic_activity) }

      it 'destroys the detail' do
        expect { economic_activity.destroy }.to change { Legend.count }.by(-1)
      end
    end
  end
end
