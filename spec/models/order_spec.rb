# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'associations' do
    it { should have_many(:order_details).dependent(:destroy) }
    it { should have_one(:order_customer).dependent(:destroy) }
    it { should belong_to(:company) }
    it { should belong_to(:invoice).optional }
  end
end
