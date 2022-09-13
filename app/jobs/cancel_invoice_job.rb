# frozen_string_literal: true

class CancelInvoiceJob < ApplicationJob
  queue_as :default

  def perform(invoice, reason)
    send_to_siat(invoice, reason)
    @invoice = invoice
    client_code = @invoice.client_code
    @company = invoice.branch_office.company
    @client = @company.clients.find_by(code: client_code)
    @reason = CancellationReason.find_by(code: reason)
    begin
      if @invoice.cancellation_date.present?
        CancellationInvoiceMailer.with(client: @client, invoice: invoice, sender: @company.mail_setting,
                                       reason: @reason).send_invoice.deliver_now
      end
    rescue StandardError => e
      p e.message
    end
  end

  def send_to_siat(invoice, reason)
    branch_office = invoice.branch_office
    daily_code = branch_office.daily_codes.current
    cuis_code = branch_office.cuis_codes.current

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
        codigoMotivo: reason,
        cuf: invoice.cuf
      }
    }
    response = client.call(:anulacion_factura, message: body)
    data = response.to_array(:anulacion_factura_response, :respuesta_servicio_facturacion).first
    puts data

    invoice.update(cancellation_date: DateTime.now, cancellation_reason_id: reason, invoice_status_id: 2) if response.success?
  end
end
