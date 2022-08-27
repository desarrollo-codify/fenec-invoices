# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MailSetting, type: :model do
  it { is_expected.to belong_to(:company) }

  let(:company) { create(:company) }
  subject { build(:mail_setting, company: company) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'address attribute' do
    it { validate_presence_of(:address) }

    context 'with nil or empty value' do
      let(:mail_setting) { build(:mail_setting, address: nil) }

      it 'is invalid' do
        expect(mail_setting).to_not be_valid
        mail_setting.address = ''
        expect(mail_setting).to_not be_valid
      end
    end
  end

  describe 'port attribute' do
    it { validate_presence_of(:port) }

    context 'with nil or empty value' do
      let(:mail_setting) { build(:mail_setting, port: nil) }

      it 'is invalid' do
        expect(mail_setting).to_not be_valid
      end
    end

    context 'validates numericality of port' do
      it { validate_numericality_of(:port).only_integer }

      context 'with non-numeric value' do
        let(:mail_setting) { build(:mail_setting, port: 'A') }

        it 'is invalid' do
          expect(mail_setting).to_not be_valid
          expect(mail_setting.errors[:port]).to eq ['El Puerto debe ser un valor numérico.']
        end
      end
    end
  end

  describe 'domain attribute' do
    it { validate_presence_of(:domain) }

    context 'with nil value' do
      let(:mail_setting) { build(:mail_setting, domain: nil) }

      it 'is invalid' do
        expect(mail_setting).to_not be_valid
      end
    end
  end

  describe 'user name attribute' do
    it { validate_presence_of(:user_name) }

    context 'with format user name' do
      let(:mail_setting) { build(:mail_setting, user_name: 'example.com') }

      it 'is not valid' do
        expect(mail_setting).to_not be_valid
        mail_setting.user_name = 'example@example'
        expect(mail_setting).to_not be_valid
      end
    end
  end

  describe 'password attribute' do
    it { validate_presence_of(:password) }

    context 'with nil value' do
      let(:mail_setting) { build(:mail_setting, password: nil) }

      it 'is not valid' do
        expect(mail_setting).to_not be_valid
        mail_setting.password = ''
        expect(mail_setting).to_not be_valid
      end
    end
  end

  describe 'company_id attribute' do
    context 'with nil value' do
      let(:mail_setting) { build(:mail_setting, company: nil) }

      it 'is invalid' do
        expect(mail_setting).to_not be_valid
      end
    end
  end
end
