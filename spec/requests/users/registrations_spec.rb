# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users::Registrations', type: :request do
  describe 'register user' do
    it 'successfully' do
      post '/auth', params: { email: 'new@example.com', password: 'password' }

      expect(User.find_by(email: 'new@example.com')).to be_truthy

      expect(response.headers['uid']).to be_truthy
      expect(response.headers['client']).to be_truthy
    end
  end
end
