# frozen_string_literal: true

class CancelInvoiceJob < ApplicationJob
  queue_as :default

  def perform(invoice)
    send_to_siat(invoice)
  end

  def send_to_siat(invoice)
    branch_office = invoice.branch_office
    daily_code = branch_office.daily_codes.last
    cuis_code = branch_office.cuis_codes.last

    client = Savon.client(
      wsdl: ENV.fetch('siat_pilot_invoices', nil),
      headers: {
        'apikey' => ENV.fetch('api_key', nil),
        'SOAPAction' => ''
      },
      namespace: ENV.fetch('siat_namespace', nil),
      convert_request_keys_to: :none
    )

    body = {
      SolicitudServicioAnulacionFactura: {
        codigoAmbiente: 2,
        codigoPuntoVenta: invoice.point_of_sale,
        codigoSistema: ENV.fetch('system_code', nil),
        codigoSucursal: branch_office.number,
        nit: branch_office.company.nit.to_i,
        codigoDocumentoSector: 1,
        codigoEmision: 1,
        codigoModalidad: 2,
        cufd: daily_code.code,
        cuis: cuis_code.code,
        tipoFacturaDocumento: 1,
        codigoMotivo: 1, # TODO: it should be @invoice.cancellation_reason_id,
        cuf: invoice.cuf
      }
    }
    response = client.call(:anulacion_factura, message: body)
    data = response.to_array(:anulacion_factura_response, :respuesta_servicio_facturacion).first
    puts data

    @invoice.update(cancellation_date: nil, cancellation_reason_id: nil) unless response.success?
    # TODO: process all possible scenarios
  end
end
