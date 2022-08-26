class InvoicingController < ActionController::Base
  require 'rqrcode'

  def show
    @invoice = scope.find(3)
    @branch_office = @invoice.branch_office
    @company = @branch_office.company
    @economic_activity = @company.economic_activities.find_by(code: @invoice.invoice_details.first.economic_activity_code)
    @literal_amount = literal_amount(@invoice.total)
    @qr_code_file = qr_code(@invoice.qr_content, @invoice.cuf)
    render pdf: "file_name",
           template: "layouts/invoice",
           page_width: '8.5cm',
           page_height: '33cm',
           page_size: nil,
           margin:  {
            top: '5mm',
            bottom: '5mm',
            left: '2mm',
            right: '2mm'
          }
  end

  private
  
  def scope
    ::Invoice.all.includes(:branch_office, invoice_details: [:measurement])
  end

  def literal_amount(amount)
    decimal = BigDecimal(amount.to_s).frac.to_s.gsub! '0.', ''

    group_by_three = amount.to_i.to_s.reverse.scan(/\d{1,3}/).map{|n| n.reverse.to_i}

    millions = [
      {true => nil, false => nil},
      {true => 'millón', false => 'millones'},
      {true => "billón", false => "billones"},
      {true => "trillón", false => "trillones"}
    ]

    previous_hundred = 0
    counter = -1
    words = group_by_three.map do |numbers|
      counter += 1
      if counter % 2 == 0
        previous_hundred = numbers
        [hundred_to_words(numbers), millions[counter/2][numbers==1]].compact if numbers > 0
      elsif previous_hundred == 0
        [hundred_to_words(numbers), "mil", millions[counter/2][false]].compact if numbers > 0
      else
        [hundred_to_words(numbers), "mil"] if numbers > 0
      end
    end

    decimales = decimal == '0' ? "00" : decimal.to_s[0..1]
    words.compact.reverse.join(' ') + ' ' + decimales + '/100'
  end

  def hundred_to_words(amount)
    specials = {
      11 => 'once', 12 => 'doce', 13 => 'trece', 14 => 'catorce', 15 => 'quince',
      10 => 'diez', 20 => 'veinte', 100 => 'cien'
    }
    if specials.has_key?(amount)
      return specials[amount]
    end

    hundreds = [nil, 'ciento', 'doscientos', 'trescientos', 'cuatrocientos', 'quinientos', 'seiscientos', 'setecientos', 'ochocientos', 'novecientos']
    tens = [nil, 'dieci', 'veinti', 'treinta', 'cuarenta', 'cincuenta', 'sesenta', 'setenta', 'ochenta', 'noventa']
    units = [nil, 'un', 'dos', 'tres', 'cuatro', 'cinco', 'seis', 'siete', 'ocho', 'nueve']

    hundred, ten, unit = amount.to_s.rjust(3,'0').scan(/\d/).map{|i| i.to_i}

    words = []
    words << hundreds[hundred]

    if specials.has_key?(ten*10 + unit)
      words << specials[ten*10 + unit]
    else
      tmp = "#{tens[ten]}#{' y ' if ten > 2 && unit > 0}#{units[unit]}"
      words << (tmp.blank? ? nil : tmp)
    end

    words.compact.join(' ')
  end

  def qr_code(content, cuf)
    qrcode = RQRCode::QRCode.new(content, level: :m)
    filename = "public/tmp/qr/#{cuf}.png"
    png = qrcode.as_png(resize_gte_to: false,
                        resize_exactly_to: false,
                        fill: 'white',
                        color: 'black',
                        size: 120,
                        border_modules: 0,
                        module_px_size: 0,
                      ).save(filename)
    return "/tmp/qr/#{cuf}.png"
  end
end
