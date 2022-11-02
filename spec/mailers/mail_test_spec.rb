require "rails_helper"

RSpec.describe MailTestMailer, type: :mailer do
  describe "send_mail" do
    let(:mail) { MailTestMailer.send_mail }

    it "renders the headers" do
      expect(mail.subject).to eq("Send mail")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
