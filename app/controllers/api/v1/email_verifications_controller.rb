# frozen_string_literal: true

module Api
  module V1
    class EmailVerificationsController < ApplicationController
      def confirm_email
        setting = CompanySetting.find_by_confirm_token(params[:id])
        if setting
          setting.email_activate
          render json: 'Se ha verificado correctamente la configuración del correo.'
        else
          render json: 'El enlace ya expiró.'
        end
      end
    end
  end
end
