# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/invoice_mailer
class InvoiceMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/invoice_mailer/prueba
  def prueba
    InvoiceMailer.prueba
  end
end
