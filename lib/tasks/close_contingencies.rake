# frozen_string_literal: true

namespace :fenectasks do
  desc 'Hola Tarola'
  task close_contingencies: :environment do
    puts 'Purging old audits...'
    Product.create(primary_code: 'Abc', description: 'Abc', company_id: 1, price: 10)
  end
end
