# frozen_string_literal: true

class CancellationInvoiceMailer < ApplicationMailer
  def send_invoice
    @client = params[:client]
    @invoice = params[:invoice]
    @reason = params[:reason]

    delivery_options = { user_name: params[:sender].user_name,
                         password: params[:sender].password,
                         domain: params[:sender].domain,
                         port: params[:sender].port,
                         address: params[:sender].address }

    mail to: @client.email, subject: 'Factura anulada', delivery_method_options: delivery_options
  end
end
