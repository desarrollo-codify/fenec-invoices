# frozen_string_literal: true
require 'siat_available'

namespace :close_contingencies do
  desc 'Close contingencies'
  task close_contingencies: :environment do
    time = Time.now
    puts "Tarea iniciada a las #{time.strftime("%H:%M:%S")} del #{time.strftime("%d/%m/%Y")}"
    api_key = Company.find(17).company_setting.api_key
    if SiatAvailable.available(api_key)
      puts 'Siat está disponible.'
      contingencies = Contingency.where(status: nil)
      if contingencies.blank?
        puts 'No hay contingencias abiertas.'
      else
        contingencies.each do |contingency|
          CloseContingencyJob.perform_now(contingency)
        end
      end
    else
      puts 'Siat no está disponible'
    end
    puts "Tarea terminada a las #{Time.now.strftime("%H:%M:%S")} del #{Time.now.strftime("%d/%m/%Y")}"
  end
end
