class Api::V1::AccountTypesController < ApplicationController
  def index
    @account_types = AccountType.all

    render json: @account_types
  end
end
