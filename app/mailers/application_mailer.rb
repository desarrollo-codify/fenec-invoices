# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'carlos.gutierrez@codify.com.bo'
  layout 'mailer'
end
