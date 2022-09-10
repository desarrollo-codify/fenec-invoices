# frozen_string_literal: true

class ApplicationController < ActionController::API
  Time.zone = 'La Paz'

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
