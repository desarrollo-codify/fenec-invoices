# frozen_string_literal: true

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  def expect_mailer_call(mailer, action, params, delivery_method = :deliver_later)
    mailer_double = instance_double(mailer)
    message_delivery_double = instance_double(ActionMailer::MessageDelivery)
    expect(mailer).to receive(:with).with(params).and_return(mailer_double)
    expect(mailer_double).to receive(action).with(no_args).and_return(message_delivery_double)
    expect(message_delivery_double).to receive(delivery_method).once
  end
end
