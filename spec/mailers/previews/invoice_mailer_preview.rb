# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/invoice_mailer
class InvoiceMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/invoice_mailer/prueba
  def send_invoice(invoice, client, xml)
    InvoiceMailer.send_invoice.with(client: client, invoice: invoice, xml: xml).post_created
  end
end
