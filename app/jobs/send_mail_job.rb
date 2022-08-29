# frozen_string_literal: true

class SendMailJob < ApplicationJob
  queue_as :default

  def perform(invoice, client, xml, sender)
    InvoiceMailer.with(client: client, invoice: invoice, xml: xml, sender: sender).send_invoice.deliver_now
  end
end
