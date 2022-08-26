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
    File.write("#{Rails.root}/tmp/factura.xml", @xml)

    attachments['factura.xml'] = File.read('/tmp/factura.xml')

    mail to: @client.email, subject: 'Factura'
  end
end
