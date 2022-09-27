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
                         address: params[:sender].address }

    xml_path = "#{Rails.root}/public/tmp/mails/#{@invoice.cuf}.xml"
    GenerateXmlJob.perform_now(@invoice) unless File.exist?(xml_path)
    attachments['factura.xml'] = File.read(xml_path)

    pdf_path = "#{Rails.root}/public/tmp/mails/#{@invoice.cuf}.pdf"
    FileUtils.rm_f(pdf_path)
    GeneratePdfJob.perform_now(@invoice)
    attachments['factura.pdf'] = File.read(pdf_path)

    mail to: @client.email, subject: 'Factura', delivery_method_options: delivery_options
    @invoice.update(emailed_at: DateTime.now)
  end
end
