# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrderDetail, type: :model do
  it { should belong_to(:order) }
end
