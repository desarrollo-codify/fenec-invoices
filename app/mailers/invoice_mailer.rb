class InvoiceMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.invoice_mailer.prueba.subject
  #
  def prueba
    @greeting = "Hi"

    mail to: "to@example.org", subject: "test mailer"
  end
end
