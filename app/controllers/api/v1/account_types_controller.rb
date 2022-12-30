# frozen_string_literal: true

module Api
  module V1
    class AccountTypesController < ApplicationController
      before_action :authenticate_user!

      def index
        @account_types = AccountType.all

        render json: @account_types
      end
    end
  end
end
