class SendMailJob < ApplicationJob
  queue_as :default

  def perform(invoice, client)
    # test mailer

    InvoiceMailer.with(client: client, invoice: invoice).send_invoice.deliver_now

    # test mailer
  end
end