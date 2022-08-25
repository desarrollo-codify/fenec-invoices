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

    mail to: 'carlos.gutierrez@codify.com.bo', subject: 'Factura'
  end
end
