# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

company = Company.create(name: 'Codify', nit: '401238026', phone: '123', address: 'En algun lugar por ahi')
BranchOffice.create(name: 'CASA MATRIZ', number: 0, city: 'Santa Cruz', company: company, address: 'por ahi', phone: '123')
Product.create(primary_code: '123', description: 'Algo bonito', company: company, sin_code: 83141)
InvoiceStatus.create(description: 'VIGENTE')
InvoiceStatus.create(description: 'ANULADA')
Client.create(code: '055', name: 'Carlos', nit: '401238026', email: 'carlos.gutierrez@codify.com.bo', company: company)
CompanySetting.create(address: 'codify.com.bo', port: 465, domain: 'codify.com.bo', user_name: 'carlos.gutierrez@codify.com.bo', password: 'Revocatongo33.', company: company)
Product.create(primary_code: '01', description: 'Configuración de servidor', price: 250, company_id: 1)
Product.create(primary_code: '02', description: 'Hosting standard por 1 año', price: 850, company_id: 1)
Product.create(primary_code: '03', description: 'Servicio por implementación de correos', price: 300, company_id: 1)
Product.create(primary_code: '04', description: 'Soporte informatico mensual', price: 350, company_id: 1)
Product.create(primary_code: '05', description: 'Arreglos de impresoras', price: 150, company_id: 1)
Product.create(primary_code: '06', description: 'Desarrollo de aplicación móvil', price: 10000, company_id: 1)