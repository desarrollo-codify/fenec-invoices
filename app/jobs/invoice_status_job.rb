# frozen_string_literal: true

class InvoiceStatusJob < ApplicationJob
  queue_as :default
  require 'siat_available'

  def perform(invoices)
    invoices.each do |invoice|
      send_invoice(invoice)
    end
  end

  def send_invoice(invoice)
    branch_office = invoice.branch_office
    cufd_code = branch_office.daily_codes.by_pos(invoice.point_of_sale).current.code
    cuis_code = branch_office.cuis_codes.by_pos(invoice.point_of_sale).current.code

    data = send_siat(branch_office, invoice, cufd_code, cuis_code)

    return unless data.present?

    description = data[:codigo_descripcion]
    code = data[:codigo_estado]
    invoice.update(process_status: description, sent_at: DateTime.now)
    invoice.invoice_logs.create(code: code, description: description)
  end

  def send_siat(branch_office, invoice, cufd_code, cuis_code)
    
    client = SiatClient.client('siat_sales_invoice_service_wsdl', branch_office.company)
    body = {
      SolicitudServicioVerificacionEstadoFactura: {
        codigoAmbiente: branch_office.company.environment_type_id,
        codigoPuntoVenta: invoice.point_of_sale,
        codigoSistema: branch_office.company.company_setting.system_code,
        codigoSucursal: branch_office.number,
        nit: branch_office.company.nit.to_i,
        codigoDocumentoSector: invoice.document_sector_code,
        codigoEmision: 1,
        codigoModalidad: branch_office.company.modality_id,
        cufd: cufd_code,
        cuis: cuis_code,
        tipoFacturaDocumento: branch_office.company.invoice_types.first.code,
        cuf: invoice.cuf
      }
    }
    begin
      response = client.call(:verificacion_estado_factura, message: body)

      response.to_array(:verificacion_estado_factura_response, :respuesta_servicio_facturacion).first
    rescue StandardError
      nil
    end
  end
end
