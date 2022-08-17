# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DelegatedToken, type: :model do
  it { is_expected.to belong_to(:company) }

  let(:company) { create(:company) }
  subject { build(:delegated_token, company: company) }

  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'token attribute' do
    it { validate_presence_of(:token) }

    context 'with nil or empty value' do
      let(:delegated_token) { build(:delegated_token, token: nil) }

      it 'is invalid' do
        expect(delegated_token).to_not be_valid
        delegated_token.token = ''
        expect(delegated_token).to_not be_valid
      end
    end
  end

  describe 'expiration_date attribute' do
    it { validate_presence_of(:expiration_date) }

    context 'with nil value' do
      let(:delegated_token) { build(:delegated_token, expiration_date: nil) }

      it 'is invalid' do
        expect(delegated_token).to_not be_valid
        delegated_token.expiration_date = ''
        expect(delegated_token).to_not be_valid
      end
    end
  end
end
