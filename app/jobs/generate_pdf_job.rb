# frozen_string_literal: true

class GeneratePdfJob < ApplicationJob
  include Rails.application.routes.url_helpers

  queue_as :default

  def perform(invoice)
    @invoice = invoice
    @branch_office = @invoice.branch_office
    @company = @branch_office.company
    @economic_activity = @company.economic_activities.first
    @literal_amount = literal_amount(@invoice.amount_payable)
    @qr_code_file = qr_code(@invoice.qr_content, @invoice.cuf)

    height = 33
    details_count = @invoice.invoice_details.count
    height += details_count - 4 if details_count > 4

    view = ActionController::Base.new
    view.view_context_class.include(ActionView::Helpers, ApplicationHelper)

    if @company.page_size_id == 1
      pdf_html = view.render_to_string(template: 'layouts/invoice',
        locals: { invoice: @invoice, branch_office: @branch_office, company: @company,
                  economic_activity: @economic_activity,
                  literal_amount: @literal_amount, qr_code_file: @qr_code_file })


      pdf_content = WickedPdf.new.pdf_from_string(
        pdf_html,
        page_width: '8.5cm',
        page_height: "#{height}cm",
        page_size: nil,
        title: '',
        margin: {
          top: '0', bottom: '0', left: '0', right: '0'
        }
      )
    else
      pdf_html = view.render_to_string(template: 'layouts/invoice-half-page',
        locals: { invoice: @invoice, branch_office: @branch_office, company: @company,
                  economic_activity: @economic_activity,
                  literal_amount: @literal_amount, qr_code_file: @qr_code_file })

      pdf_content = WickedPdf.new.pdf_from_string(
        pdf_html,
        page_width: '216mm',
        page_height: "279mm",
        page_size: 'A4',
        title: '',
        margin: {
          top: '0', bottom: '0', left: '1cm', right: '1cm'
        }
      )
    end
    debugger

    pdf_path = "#{Rails.root}/public/tmp/mails/#{@invoice.cuf}.pdf"

    return if File.exist?(pdf_path)

    File.open(pdf_path, 'wb') do |file|
      file << pdf_content
      file.close
    end
  end

  private

  def literal_amount(amount)
    return 'Cero 00/100' if amount.zero?

    decimal = BigDecimal(amount.to_s).frac.to_s.gsub! '0.', ''

    group_by_three = amount.to_i.to_s.reverse.scan(/\d{1,3}/).map { |n| n.reverse.to_i }

    millions = [
      { true => nil, false => nil },
      { true => 'millón', false => 'millones' },
      { true => 'billón', false => 'billones' },
      { true => 'trillón', false => 'trillones' }
    ]

    previous_hundred = 0
    counter = -1
    words = group_by_three.map do |numbers|
      counter += 1
      if counter.even?
        previous_hundred = numbers
        [hundred_to_words(numbers), millions[counter / 2][numbers == 1]].compact if numbers.positive?
      elsif previous_hundred.zero?
        [hundred_to_words(numbers), 'mil', millions[counter / 2][false]].compact if numbers.positive?
      elsif numbers.positive?
        [hundred_to_words(numbers), 'mil']
      end
    end

    decimales = decimal == '0' ? '00' : decimal.to_s[0..1]
    "#{words.compact.reverse.join(' ')} #{decimales}/100"
  end

  def hundred_to_words(amount)
    specials = {
      11 => 'once', 12 => 'doce', 13 => 'trece', 14 => 'catorce', 15 => 'quince',
      10 => 'diez', 20 => 'veinte', 100 => 'cien'
    }
    return specials[amount] if specials.key?(amount)

    hundreds = [nil, 'ciento', 'doscientos', 'trescientos', 'cuatrocientos', 'quinientos', 'seiscientos', 'setecientos',
                'ochocientos', 'novecientos']
    tens = [nil, 'dieci', 'veinti', 'treinta', 'cuarenta', 'cincuenta', 'sesenta', 'setenta', 'ochenta', 'noventa']
    units = [nil, 'un', 'dos', 'tres', 'cuatro', 'cinco', 'seis', 'siete', 'ocho', 'nueve']

    hundred, ten, unit = amount.to_s.rjust(3, '0').scan(/\d/).map(&:to_i)

    words = []
    words << hundreds[hundred]

    if specials.key?((ten * 10) + unit)
      words << specials[(ten * 10) + unit]
    else
      tmp = "#{tens[ten]}#{' y ' if ten > 2 && unit.positive?}#{units[unit]}"
      words << (tmp.blank? ? nil : tmp)
    end

    words.compact.join(' ')
  end

  def qr_code(content, cuf)
    qrcode = RQRCode::QRCode.new(content, level: :m)
    filename = "public/tmp/qr/#{cuf}.png"
    qrcode.as_png(resize_gte_to: false,
                  resize_exactly_to: false,
                  fill: 'white',
                  color: 'black',
                  size: 150,
                  border_modules: 0,
                  module_px_size: 0).save(filename)
    filename
  end
end
