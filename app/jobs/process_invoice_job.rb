# frozen_string_literal: true

class ProcessInvoiceJob < ApplicationJob
  queue_as :default

  require 'siat_available'
  require 'generate_cufd'

  def perform(invoice, point_of_sale, economic_activity)
    pending_contingency_exists = pending_contingency?(point_of_sale)
    contingency = current_contingency(point_of_sale)
    is_siat_available = siat_available?(invoice)
    if is_siat_available
      if pending_contingency_exists && contingency.present?
        generate_cufd(point_of_sale)
        close_contingency(contingency)
      end
    else
      # TODO: don't send a magic number like 2, use an enum or something similar
      create_contingency(point_of_sale, invoice.date, invoice.cufd_code, 2) unless pending_contingency?(point_of_sale)
    end
    process_pending_data(invoice, point_of_sale, is_siat_available, economic_activity)
    generate_invoice_documents(invoice)
    send_mail(invoice)

    return if invoice.is_manual

    sent_to_siat(invoice) if is_siat_available
  end

  private

  def siat_available?(invoice)
    SiatAvailable.available(invoice.branch_office.company.company_setting.api_key)
  end

  def pending_contingency?(point_of_sale)
    point_of_sale.contingencies.automatic.pending.any?
  end

  def current_contingency(point_of_sale)
    point_of_sale.contingencies.pending.automatic.first
  end

  def close_contingency(contingency)
    CloseContingencyJob.perform_later(contingency)
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
      invoice.update(emailed_at: DateTime.now)
    rescue StandardError => e
      p e.message
    end
  end

  def sent_to_siat(invoice)
    SendInvoiceJob.perform_later(invoice)
  end

  def current_daily_code(branch_office, point_of_sale)
    branch_office.daily_codes.where(point_of_sale: point_of_sale.code).current
  end

  def process_cafc(invoice, economic_activity, point_of_sale)
    contingency = invoice.branch_office.point_of_sales.find_by(code: point_of_sale.code).contingencies.pending.manual.last
    contingency_code = economic_activity.contingency_codes.available.first
    contingency_code.increment!
    contingency.significative_event_id >= 5 ? contingency_code.code : nil
  end

  def daily_code(invoice, point_of_sale)
    if invoice.is_manual
      contingency = point_of_sale.contingencies.pending.manual.first
      daily_code = point_of_sale.branch_office.daily_codes.find_by(code: contingency.cufd_code)
    else
      daily_code = current_daily_code(invoice.branch_office, point_of_sale)
    end
    daily_code
  end

  def process_pending_data(invoice, point_of_sale, siat_available, economic_activity)
    daily_code = daily_code(invoice, point_of_sale)
    invoice.cufd_code = daily_code.code
    invoice.control_code = daily_code.control_code
    invoice.number = invoice_number(point_of_sale)
    invoice.cuf = cuf(invoice.date, invoice.number, invoice.control_code, point_of_sale)
    # TODO: implement paper size: 1 roll, 2 half office or half letter
    invoice.qr_content = qr_content(invoice.company_nit, invoice.cuf, invoice.number, 1)
    invoice.cafc = process_cafc(invoice, economic_activity, point_of_sale) if invoice.is_manual
    if !siat_available || invoice.is_manual
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
