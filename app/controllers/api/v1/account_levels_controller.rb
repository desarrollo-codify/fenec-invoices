# frozen_string_literal: true

module Api
  module V1
    class AccountLevelsController < ApplicationController
      before_action :authenticate_user!

      def index
        @account_levels = AccountLevel.all

        render json: @account_levels
      end
    end
  end
end
