class MailTestMailer < ApplicationMailer
  def send_mail
    @email = params[:email]
    @company = params[:company]
    delivery_options = { user_name: @company.company_setting.user_name,
                         password: @company.company_setting.password,
                         domain: @company.company_setting.domain,
                         port: @company.company_setting.port,
                         address: @company.company_setting.address }
    mail to: @email, subject: 'Prueba', delivery_method_options: delivery_options
  end
end
