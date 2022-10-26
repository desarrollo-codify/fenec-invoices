# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

page_size = PageSize.create(description: 'Roll')
PageSize.create(description: 'Half page')
company = Company.create(name: 'DomiUp SRL', nit: '401238026', phone: '77766655', address: 'Prolongacion Beni Edif. Top Center',
    page_size_id: page_size.id)
BranchOffice.create(name: 'CASA MATRIZ', number: 0, city: 'Santa Cruz', company_id: 1, address: 'Prolongacion Beni Edif. Top Center', 
  phone: '77766655')
InvoiceStatus.create(description: 'VIGENTE')
InvoiceStatus.create(description: 'ANULADA')
DocumentType.create(description: 'Carnet de Identidad')
Client.create(code: '00001', name: 'Juan Perez', nit: '123456', email: 'carlos.gutierrez@codify.com.bo', company_id: company.id, document_type_id: 1)
Client.create(code: '00002', name: 'Napoleon Bonaparte', nit: '8888887777', email: 'roger.vaca@codify.com.bo', company_id: 1, document_type_id: 1)
CompanySetting.create(address: 'codify.com.bo', port: 465, domain: 'codify.com.bo', user_name: 'carlos.gutierrez@codify.com.bo', 
  password: 'Revocatongo33.', company_id: 1)
Product.create(primary_code: '001', description: 'Configuración de servidor', price: 250, company_id: 1)
Product.create(primary_code: '002', description: 'Hosting standard por 1 año', price: 850, company_id: 1)
Product.create(primary_code: '003', description: 'Servicio por implementación de correos', price: 300, company_id: 1)
Product.create(primary_code: '004', description: 'Soporte informatico mensual', price: 350, company_id: 1)
Product.create(primary_code: '005', description: 'Arreglos de impresoras', price: 150, company_id: 1)
Product.create(primary_code: '006', description: 'Desarrollo de aplicación móvil', price: 10000, company_id: 1)

EnvironmentType.create(description: 'Producción')
EnvironmentType.create(description: 'Pruebas y Piloto')

Modality.create(description: 'Electrónica en Línea')
Modality.create(description: 'Computarizada en Línea')

