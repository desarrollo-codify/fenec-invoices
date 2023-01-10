namespace :test do
  desc "Tarea de prueba"
  task task_test: :environment do
    time = Time.now
    puts "Tarea iniciada a las #{time.strftime("%H:%M:%S")} del #{time.strftime("%d/%m/%Y")}"
    user = User.find(12)
    company = Company.find(17)
    MailTestMailer.with(email: user.email, company: company).send_mail.deliver_now
    puts "Tarea terminada a las #{Time.now.strftime("%H:%M:%S")} del #{Time.now.strftime("%d/%m/%Y")}"
  end
end

