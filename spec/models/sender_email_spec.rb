# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompanySetting, type: :model do
  it { is_expected.to belong_to(:company) }

  let(:company) { create(:company) }
  subject { build(:company_setting, company: company) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'address attribute' do
    it { validate_presence_of(:address) }

    context 'with nil or empty value' do
      let(:company_setting) { build(:company_setting, address: nil) }

      it 'is invalid' do
        expect(company_setting).to_not be_valid
        company_setting.address = ''
        expect(company_setting).to_not be_valid
      end
    end
  end

  describe 'port attribute' do
    it { validate_presence_of(:port) }

    context 'with nil or empty value' do
      let(:company_setting) { build(:company_setting, port: nil) }

      it 'is invalid' do
        expect(company_setting).to_not be_valid
      end
    end

    context 'validates numericality of port' do
      it { validate_numericality_of(:port).only_integer }

      context 'with non-numeric value' do
        let(:company_setting) { build(:company_setting, port: 'A') }

        it 'is invalid' do
          expect(company_setting).to_not be_valid
          expect(company_setting.errors[:port]).to eq ['El Puerto debe ser un valor numérico.']
        end
      end
    end
  end

  describe 'domain attribute' do
    it { validate_presence_of(:domain) }

    context 'with nil value' do
      let(:company_setting) { build(:company_setting, domain: nil) }

      it 'is invalid' do
        expect(company_setting).to_not be_valid
      end
    end
  end

  describe 'user name attribute' do
    it { validate_presence_of(:user_name) }

    context 'with format user name' do
      let(:company_setting) { build(:company_setting, user_name: 'example.com') }

      it 'is not valid' do
        expect(company_setting).to_not be_valid
        company_setting.user_name = 'example@example'
        expect(company_setting).to_not be_valid
      end
    end
  end

  describe 'password attribute' do
    it { validate_presence_of(:password) }

    context 'with nil value' do
      let(:company_setting) { build(:company_setting, password: nil) }

      it 'is not valid' do
        expect(company_setting).to_not be_valid
        company_setting.password = ''
        expect(company_setting).to_not be_valid
      end
    end
  end

  describe 'company_id attribute' do
    context 'with nil value' do
      let(:company_setting) { build(:company_setting, company: nil) }

      it 'is invalid' do
        expect(company_setting).to_not be_valid
      end
    end
  end
end
