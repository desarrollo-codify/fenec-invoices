# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_user!
      before_action :set_user, except: %i[index create]

      def index
        users = params[:company_id].present? ? User.by_company(params[:company_id]).includes(:company) : User.all.includes(:company)

        render json: users.as_json(only: %i[id full_name username role email company_id],
                                   include: [{ company: { only: :name } }])
      end

      def show
        render json: @user.as_json(only: %i[id full_name username role email default_password company_id],
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

      def default_password
        @user.update(password: 'Llave123.', password_confirmation: 'Llave123.', default_password: true)

        render json: { message: 'Se ha restablecido la contraseña' }, status: :ok
      end

      def reset_password
        if @user.update(reset_user_params)
          @user.update(default_password: false)
          render json: { message: 'Se ha cambiado correctamente la contraseña' }
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

      def reset_user_params
        params.require(:user).permit(:password, :password_confirmation)
      end
    end
  end
end
