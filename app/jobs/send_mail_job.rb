# frozen_string_literal: true

class SendMailJob < ApplicationJob
  queue_as :default

  def perform(invoice, client, xml)
    # test mailer

    InvoiceMailer.with(client: client, invoice: invoice, xml: xml).send_invoice.deliver_now

    # test mailer
  end
end
