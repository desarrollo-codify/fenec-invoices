# frozen_string_literal: true

class MailTestMailer < ApplicationMailer
  def send_mail
    @email = params[:email]
    @company = params[:company]
    delivery_options = { user_name: @company.company_setting.user_name,
                         password: @company.company_setting.password,
                         domain: @company.company_setting.domain,
                         port: @company.company_setting.port,
                         address: @company.company_setting.address,
                         openssl_verify_mode: @company.company_setting.is_secure ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE,
                         ssl: @company.company_setting.is_secure,
                         tls: @company.company_setting.is_secure
                      }
    debugger
    mail to: @email, from: @company.company_setting.user_name, subject: 'Correo de verificación', delivery_method_options: delivery_options
  end
end
