# frozen_string_literal: true

class InvoiceMailer < ApplicationMailer
  include ActionController::Helpers
  helper ApplicationHelper

  def send_invoice
    @client = params[:client]
    @invoice = params[:invoice]
    xml = params[:xml]

    @branch_office = @invoice.branch_office
    @company = @branch_office.company
    @economic_activity = @company.economic_activities.first
    @literal_amount = literal_amount(@invoice.total)
    @qr_code_file = qr_code(@invoice.qr_content, @invoice.cuf)

    delivery_options = { user_name: params[:sender].user_name,
                         password: params[:sender].password,
                         domain: params[:sender].domain,
                         port: params[:sender].port,
                         address: params[:sender].address }

    filename = "#{Rails.root}/tmp/mails/#{@invoice.cuf}.xml"
    File.write(filename, xml)
    attachments['factura.xml'] = File.read(filename)

    # TODO: make dynamic
    options = {
      page_height: '33cm'
    }

    pdf = WickedPdf.new.pdf_from_string(
      render_to_string(
        pdf: 'file_name',
        template: 'layouts/invoice',
        page_width: '8.5cm',
        page_height: '33cm',
        page_size: nil,
        title: '',
        margin: {
          top: '5mm',
          bottom: '5mm',
          left: '2mm',
          right: '2mm'
        }
      ),
      options
    )

    pdf_path = "#{Rails.root}/tmp/mails/#{@invoice.cuf}.pdf"
    File.open(pdf_path, 'wb') do |file|
      file << pdf
      file.close
    end

    attachments['factura.pdf'] = File.read(pdf_path)
    # TODO: use dynamic email subject
    mail to: @client.email, subject: 'Factura', delivery_method_options: delivery_options
  end

  def literal_amount(amount)
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
