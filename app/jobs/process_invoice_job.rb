# frozen_string_literal: true

class ProcessInvoiceJob < ApplicationJob
  queue_as :default

  require 'siat_available'
  require 'generate_cufd'

  def perform(invoice, point_of_sale)
    pending_contingency_exists = pending_contingency?(point_of_sale)
    is_siat_available = siat_available?(invoice)
    if is_siat_available
      if pending_contingency_exists
        generate_cufd(point_of_sale)
        close_contingency(point_of_sale)
      end
    else
      # TODO: don't send a magic number like 2, use an enum or something similar
      create_contingency(point_of_sale, invoice.date, invoice.cufd_code, 2) unless pending_contingency?(point_of_sale)
    end

    process_pending_data(invoice, point_of_sale, is_siat_available)
    generate_invoice_documents(invoice)

    send_mail(invoice)
    sent_to_siat(invoice)
  end

  private

  def siat_available?(invoice)
    SiatAvailable.available(invoice, true)
  end

  def pending_contingency?(point_of_sale)
    point_of_sale.contingencies.pending.any?
  end

  def current_contingency(point_of_sale)
    point_of_sale.contingencies.pending.first
  end

  def close_contingency(point_of_sale)
    CloseContingencyJob.perform_later(current_contingency(point_of_sale))
  end

  def generate_cufd(point_of_sale)
    GenerateCufd.generate(point_of_sale)
  end

  def create_contingency(point_of_sale, start_date, cufd_code, significative_event_id)
    CreateContingencyJob.perform_later(point_of_sale, start_date, cufd_code, significative_event_id)
  end

  def generate_invoice_documents(invoice)
    GenerateXmlJob.perform_now(invoice)
    GeneratePdfJob.perform_now(invoice)
  end

  def send_mail(invoice)
    company = invoice.branch_office.company
    client = company.clients.find_by(code: invoice.client_code)
    begin
      InvoiceMailer.with(client: client, invoice: invoice, sender: company.company_setting).send_invoice.deliver_now
    rescue StandardError => e
      p e.message
    end
  end

  def sent_to_siat(invoice)
    SendInvoiceJob.perform_later(invoice)
  end

  def process_pending_data(invoice, point_of_sale, siat_available)
    invoice.number = invoice_number(point_of_sale)
    invoice.cuf = cuf(invoice.date, invoice.number, invoice.control_code, point_of_sale)
    # TODO: implement paper size: 1 roll, 2 half office or half letter
    invoice.qr_content = qr_content(invoice.company_nit, invoice.cuf, invoice.number, 1)
    unless siat_available
      # rubocop:disable Layout/LineLength
      invoice.graphic_representation_text = 'Este documento es la Representación Gráfica de un Documento Fiscal Digital emitido fuera de línea, verifique su envío con su proveedor o en la página web www.impuestos.gob.bo.'
      # rubocop:enable Layout/LineLength
    end
    invoice.save
  end

  def cuf(invoice_date, current_number, control_code, point_of_sale)
    branch_office = point_of_sale.branch_office
    nit = branch_office.company.nit.rjust(13, '0')
    date = invoice_date.strftime('%Y%m%d%H%M%S%L')
    branch_office_number = branch_office.number.to_s.rjust(4, '0')
    modality = '2' # TODO: save modality in company or branch office
    generation_type = '1' # TODO: add generation types for: online, offline and massive
    invoice_type = '1' # TODO: add invoice types table
    sector_document_type = '1'.rjust(2, '0') # TODO: add sector types table
    number = current_number.to_s.rjust(10, '0')
    point_of_sale_number = point_of_sale.code.to_s.rjust(4, '0')

    long_code = nit + date + branch_office_number + modality + generation_type + invoice_type + sector_document_type + number +
                point_of_sale_number
    mod_11_value = module_eleven(long_code, 9)
    hex_code = hex_base(mod_11_value.to_i)
    (hex_code + control_code).upcase
  end

  def invoice_number(point_of_sale)
    branch_office = point_of_sale.branch_office
    cuis_code = branch_office.cuis_codes.where(point_of_sale: point_of_sale.code).current
    current_number = cuis_code.current_number
    cuis_code.increment!
    current_number
  end

  def module_eleven(code, limit)
    sum = 0
    multiplier = 2
    code.reverse.each_char.with_index do |character, _i|
      sum += multiplier * character.to_i
      multiplier += 1
      multiplier = 2 if multiplier > limit
    end
    digit = sum % 11
    last_char = digit == 10 ? '1' : digit.to_s
    code + last_char
  end

  def hex_base(value)
    value.to_s(16)
  end

  def qr_content(nit, cuf, number, page_size)
    base_url = ENV.fetch('siat_url', nil)
    params = { nit: nit, cuf: cuf, numero: number, t: page_size }
    "#{base_url}?#{params.to_param}"
  end
end
