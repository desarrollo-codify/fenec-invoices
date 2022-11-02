class Api::V1::AccountLevelsController < ApplicationController
  def index
    @account_levels = AccountLevel.all

    render json: @account_levels
  end
end
