# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users::Sessions', type: :request do
  describe 'log in' do
    it 'successfully' do
      user = User.create(email: 'test@example.com', password: 'password')

      post '/auth/sign_in', params: { email: 'test@example.com', password: 'password' }

      expect(response.headers['uid']).to eq(user.uid)
    end

    it 'unsuccessfully' do
      user = User.create(email: 'test@example.com', password: 'password')

      post '/auth/sign_in', params: { email: 'test@example.com', password: 'aa' }

      expect(response.headers['uid']).to_not eq(user.uid)
    end
  end
end
