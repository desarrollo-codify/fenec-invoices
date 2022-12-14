# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrderCustomer, type: :model do
  it { should belong_to(:order) }
end
