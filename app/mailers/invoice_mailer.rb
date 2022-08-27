# frozen_string_literal: true

class InvoiceMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.invoice_mailer.prueba.subject
  #
  def send_invoice
    @client = params[:client]
    @invoice = params[:invoice]
    @xml = params[:xml]

    delivery_options = { user_name: params[:sender].user_name,
                         password: params[:sender].password,
                         domain: params[:sender].domain,
                         port: params[:sender].port,
                         address: params[:sender].address }

    filename = "#{Rails.root}/tmp/mails/#{@invoice.cuf}.xml"
    File.write(filename, @xml)

    attachments['factura.xml'] = File.read(filename)

    mail to: @client.email, subject: 'Factura', delivery_method_options: delivery_options
    File.delete(filename)
  end
end
