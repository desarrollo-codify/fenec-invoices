# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/mail_test
class MailTestPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/mail_test/send_mail
  def send_mail
    MailTestMailer.send_mail
  end
end
