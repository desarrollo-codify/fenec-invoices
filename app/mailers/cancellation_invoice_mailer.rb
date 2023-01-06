# frozen_string_literal: true

class CancellationInvoiceMailer < ApplicationMailer
  def send_invoice
    @customer = params[:customer]
    @invoice = params[:invoice]
    @reason = params[:reason]

    delivery_options = { user_name: params[:sender].user_name,
                         password: params[:sender].password,
                         domain: params[:sender].domain,
                         port: params[:sender].port,
                         address: params[:sender].address,
                         openssl_verify_mode: params[:sender].is_secure ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE,
                         ssl: params[:sender].is_secure,
                         tls: params[:sender].is_secure }

    mail to: @customer.email, from: params[:sender].user_name, subject: 'Factura anulada', delivery_method_options: delivery_options
  end
end
