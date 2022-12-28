# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Orders', type: :request do
  before(:all) do
    @user = create(:user)
    @auth_headers = @user.create_new_auth_token
  end
  
  after(:all) do
    @user.destroy  
  end
  
  describe 'PUT /update' do
    let(:new_attributes) { { total_discount: 10 } }
    let(:order) { create(:order) }
    
    it 'returns http success' do
      put api_v1_order_url(order),
            params: { order: new_attributes },headers: @auth_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
    end
  end
end
