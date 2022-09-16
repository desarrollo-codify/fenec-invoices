# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

company = Company.create(name: 'DomiUp SRL', nit: '401238026', phone: '77766655', address: 'Prolongacion Beni Edif. Top Center')
BranchOffice.create(name: 'CASA MATRIZ', number: 0, city: 'Santa Cruz', company: company, address: 'Prolongacion Beni Edif. Top Center', phone: '77766655')
InvoiceStatus.create(description: 'VIGENTE')
InvoiceStatus.create(description: 'ANULADA')
Client.create(code: '001', name: 'Juan Perez', nit: '123456', email: 'carlos.gutierrez@codify.com.bo', company_id: 1, document_type_id: 1)
CompanySetting.create(address: 'codify.com.bo', port: 465, domain: 'codify.com.bo', user_name: 'carlos.gutierrez@codify.com.bo', password: 'Revocatongo33.', company: company)
Product.create(primary_code: '01', description: 'Configuración de servidor', price: 250, company_id: 1)
Product.create(primary_code: '02', description: 'Hosting standard por 1 año', price: 850, company_id: 1)
Product.create(primary_code: '03', description: 'Servicio por implementación de correos', price: 300, company_id: 1)
Product.create(primary_code: '04', description: 'Soporte informatico mensual', price: 350, company_id: 1)
Product.create(primary_code: '05', description: 'Arreglos de impresoras', price: 150, company_id: 1)
Product.create(primary_code: '06', description: 'Desarrollo de aplicación móvil', price: 10000, company_id: 1)