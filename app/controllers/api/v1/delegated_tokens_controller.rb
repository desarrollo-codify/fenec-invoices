# frozen_string_literal: true

module Api
  module V1
    class DelegatedTokensController < ApplicationController
      before_action :set_delegated_token, only: %i[show update destroy]
      before_action :set_company, only: %i[index create]

      def index
        @delegated_tokens = @company.delegated_tokens
        render json: @delegated_tokens
      end

      def show
        render json: @delegated_token
      end

      def create
        @delegated_token = @company.delegated_tokens.build(delegated_token_params)

        if @delegated_token.save
          render json: @delegated_token, status: :created
        else
          render json: @delegated_token.errors, status: :unprocessable_entity
        end
      end

      def update
        if @delegated_token.update(delegated_token_params)
          render json: @delegated_token
        else
          render json: @delegated_token.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @delegated_token.destroy
      end

      private

      def set_delegated_token
        @delegated_token = DelegatedToken.find(params[:id])
      end

      def set_company
        @company = Company.find(params[:company_id])
      end

      def delegated_token_params
        params.require(:delegated_token).permit(:token, :expiration_date)
      end
    end
  end
end
