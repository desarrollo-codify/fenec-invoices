# frozen_string_literal: true

class SendInvoiceJob < ApplicationJob
  queue_as :default
  require 'siat_client'

  def perform(invoice)
    client = SiatClient.client('siat_sales_invoice_service_wsdl', invoice.branch_office.company)

    filename = "#{Rails.root}/public/tmp/mails/#{invoice.cuf}.xml"
    zipped_filename = "#{filename}.gz"

    Zlib::GzipWriter.open(zipped_filename) do |gz|
      gz.write File.binread(filename)
    end

    base64_file = generate_gzip_file(invoice)
    body = {
      SolicitudServicioRecepcionFactura: {
        codigoAmbiente: invoice.branch_office.company.environment_type_id,
        codigoPuntoVenta: invoice.point_of_sale,
        codigoSistema: invoice.branch_office.company.company_setting.system_code,
        codigoSucursal: invoice.branch_office.number,
        nit: invoice.branch_office.company.nit.to_i,
        codigoDocumentoSector: invoice.branch_office.company.document_types.first.code,
        codigoEmision: 1,
        codigoModalidad: invoice.branch_office.company.modality_id,
        cufd: invoice.cufd_code,
        cuis: invoice.branch_office.cuis_codes.where(point_of_sale: invoice.point_of_sale).current.code,
        tipoFacturaDocumento: invoice.branch_office.company.invoice_types.first.code,
        archivo: base64_file,
        fechaEnvio: DateTime.now.strftime('%Y-%m-%dT%H:%M:%S.%L'),
        hashArchivo: file_hash(base64_file)
      }
    }
    begin
      response = client.call(:recepcion_factura, message: body)
      data = response.to_array(:recepcion_factura_response, :respuesta_servicio_facturacion).first
      update_invoice(invoice) if data[:codigo_estado] == '908'
    rescue StandardError => e
      invoice.invoice_logs.create(code: '1000',
                                  description: "No se pudo enviar la factura al SIAT debido al siguiente error #{e}")
    end
  end

  private

  def generate_gzip_file(invoice)
    filename = "#{Rails.root}/public/tmp/mails/#{invoice.cuf}.xml"
    zipped_filename = "#{filename}.gz"

    Zlib::GzipWriter.open(zipped_filename) do |gz|
      gz.write File.binread(filename)
    end
    Base64.strict_encode64(File.binread(zipped_filename))
  end

  def file_hash(file)
    Digest::SHA2.hexdigest(file)
  end

  def update_invoice(invoice)
    invoice.update(sent_at: DateTime.now, process_status: 'VALIDA')
  end
end
