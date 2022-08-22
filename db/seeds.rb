# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

company = Company.create(name: 'Codify', nit: '401238026', address: 'En algun lugar por ahi')
BranchOffice.create(name: 'CASA MATRIZ', number: 0, city: 'Santa Cruz', company: company)
Product.create(primary_code: '123', description: 'Algo bonito', company: company)
InvoiceStatus.create(description: 'VIGENTE')
InvoiceStatus.create(description: 'ANULADA')
