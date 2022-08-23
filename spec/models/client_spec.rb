# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Client, type: :model do
  it { is_expected.to belong_to(:company) }

  let(:company) { create(:company) }
  subject { build(:client, company: company) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'name attribute' do
    it { validate_presence_of(:name) }

    context 'with nil or empty value' do
      let(:client) { build(:client, name: nil) }

      it 'is invalid' do
        expect(client).to_not be_valid
        client.name = ''
        expect(client).to_not be_valid
      end
    end

    context 'with special characters' do
      let(:client) { build(:client, name: '#$%') }

      it 'is not valid' do
        expect(client).to_not be_valid
      end
    end

    context 'with accents' do
      let(:client) { build(:client, name: 'áü') }

      it 'is valid' do
        expect(client).to be_valid
      end
    end
  end

  describe 'nit attribute' do
    it { validate_presence_of(:nit) }

    context 'with nil value' do
      let(:client) { build(:client, nit: nil) }

      it 'is invalid' do
        expect(client).to_not be_valid
      end
    end

    context 'validates numericality of nit' do
      it { validate_numericality_of(:nit).only_integer }

      describe 'with a non-numeric value' do
        let(:client) { build(:client, nit: 'ABC') }

        it 'is invalid' do
          expect(client).to_not be_valid
          expect(client.errors[:nit]).to eq(['El NIT debe ser un valor numérico.'])
        end
      end
    end
  end

  describe 'email attribute' do
    context 'with format email' do
      let(:client) { build(:client, email: 'example.com') }

      it 'is not valid' do
        expect(client).to_not be_valid
        client.email = 'example@example'
        expect(client).to_not be_valid
      end
    end
  end

  describe 'company_id attribute' do
    context 'with nil value' do
      let(:client) { build(:client, company: nil) }

      it 'is invalid' do
        expect(client).to_not be_valid
      end
    end
  end
end
