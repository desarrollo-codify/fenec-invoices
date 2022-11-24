# frozen_string_literal: true

class InvoiceMailer < ApplicationMailer
  include ActionController::Helpers
  helper ApplicationHelper

  def send_invoice
    @client = params[:client]
    @invoice = params[:invoice]
    delivery_options = { user_name: params[:sender].user_name,
                         password: params[:sender].password,
                         domain: params[:sender].domain,
                         port: params[:sender].port,
                         address: params[:sender].address,
                         openssl_verify_mode: params[:sender].is_secure ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE,
                         ssl: params[:sender].is_secure,
                         tls: params[:sender].is_secure }
    xml_path = "#{Rails.root}/public/tmp/mails/#{@invoice.cuf}.xml"
    GenerateXmlJob.perform_now(@invoice) unless File.exist?(xml_path)
    attachments['factura.xml'] = File.read(xml_path)

    pdf_path = "#{Rails.root}/public/tmp/mails/#{@invoice.cuf}.pdf"

    GeneratePdfJob.perform_now(@invoice) unless File.exist?(pdf_path)
    attachments['factura.pdf'] = File.read(pdf_path)

    mail to: @client.email,, from: params[:sender].user_name, subject: 'Factura', delivery_method_options: delivery_options
  end
end
