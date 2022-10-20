# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_user, except: %i[index create]

      def index
        users = params[:company_id].present? ? User.by_company(params[:company_id]).includes(:company) : User.all.includes(:company)

        render json: users.as_json(only: %i[id full_name username role email company_id],
                                   include: [{ company: { only: :name } }])
      end

      def show
        render json: @user.as_json(only: %i[id full_name username role email company_id],
                                   include: [{ company: { only: :name } }])
      end

      def create
        @user = User.new(user_params)

        if @user.save
          render json: @user.as_json(only: %i[id full_name username role email company_id],
                                     include: [{ company: { only: :name } }]),
                 status: :created
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

      def update
        if @user.update(update_user_params)
          render json: @user.as_json(only: %i[id full_name username role email company_id],
                                     include: [{ company: { only: :name } }])
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @user.destroy
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.require(:user).permit(:full_name, :username, :role, :email, :password, :password_confirmation, :company_id)
      end

      def update_user_params
        params.require(:user).permit(:full_name, :username, :role, :company_id)
      end
    end
  end
end
