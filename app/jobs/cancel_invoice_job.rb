# frozen_string_literal: true

class CancelInvoiceJob < ApplicationJob
  queue_as :default
  require 'siat_available'

  def perform(invoice, reason)
    return unless SiatAvailable.available(invoice.branch_office.company.company_setting.api_key)

    invoice.update(invoice_status_id: 2, cancel_sent_at: true) if send_to_siat(invoice, reason)
    @invoice = invoice
    client_code = @invoice.client_code
    @company = invoice.branch_office.company
    @client = @company.clients.find_by(code: client_code)
    @reason = CancellationReason.find_by(code: reason)
    begin
      if @invoice.cancellation_date.present?
        CancellationInvoiceMailer.with(client: @client, invoice: invoice, sender: @company.company_setting,
                                       reason: @reason).send_invoice.deliver_now
      end
    rescue StandardError => e
      p e.message
    end
  end

  def send_to_siat(invoice, reason)
    branch_office = invoice.branch_office
    daily_code = branch_office.daily_codes.where(point_of_sale: invoice.point_of_sale).current
    cuis_code = branch_office.cuis_codes.where(point_of_sale: invoice.point_of_sale).current

    client = Savon.client(
      wsdl: ENV.fetch('siat_pilot_invoices', nil),
      headers: {
        'apikey' => branch_office.company.company_setting.api_key,
        'SOAPAction' => ''
      },
      namespace: ENV.fetch('siat_namespace', nil),
      convert_request_keys_to: :none
    )

    body = {
      SolicitudServicioAnulacionFactura: {
        codigoAmbiente: 2,
        codigoPuntoVenta: invoice.point_of_sale,
        codigoSistema: branch_office.company.company_setting.system_code,
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

    response.success?
  end
end
