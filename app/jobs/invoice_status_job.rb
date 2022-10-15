# frozen_string_literal: true

class InvoiceStatusJob < ApplicationJob
  queue_as :default

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
    client = Savon.client(
      wsdl: ENV.fetch('siat_pilot_invoices'.to_s, nil),
      headers: {
        'apikey' => branch_office.company.company_setting.api_key,
        'SOAPAction' => ''
      },
      namespace: ENV.fetch('siat_namespace', nil),
      convert_request_keys_to: :none
    )
    body = {
      SolicitudServicioVerificacionEstadoFactura: {
        codigoAmbiente: 2,
        codigoPuntoVenta: invoice.point_of_sale,
        codigoSistema: branch_office.company.company_setting.system_code,
        codigoSucursal: branch_office.number,
        nit: branch_office.company.nit.to_i,
        codigoDocumentoSector: invoice.document_sector_code,
        codigoEmision: 1,
        codigoModalidad: 2,
        cufd: cufd_code,
        cuis: cuis_code,
        tipoFacturaDocumento: 1,
        cuf: invoice.cuf
      }
    }
    response = client.call(:verificacion_estado_factura, message: body)

    return unless response.success?

    response.to_array(:verificacion_estado_factura_response, :respuesta_servicio_facturacion).first
  end
end