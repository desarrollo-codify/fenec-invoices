# frozen_string_literal: true

class SendCancelInvoicesJob < ApplicationJob
  queue_as :default
  require 'siat_client'

  def perform(contingency)
    # TODO: refactor this and filter by branch office or company or point_of_sale
    point_of_sale = contingency.point_of_sale
    invoices = point_of_sale.branch_office.invoices.by_point_of_sale(point_of_sale.code).for_sending_cancel
    invoices.each do |invoice|
      cancel = send_to_siat(invoice, invoice.cancellation_reason_id)

      next unless cancel

      @invoice = invoice
      client_code = @invoice.client_code
      @company = invoice.branch_office.company
      @client = @company.clients.find_by(code: client_code)
      @reason = CancellationReason.find_by(code: invoice.cancellation_reason_id)
      begin
        if @invoice.cancellation_date.present?
          CancellationInvoiceMailer.with(client: @client, invoice: @invoice, sender: @company.company_setting,
                                         reason: @reason).send_invoice.deliver_now
        end
      rescue StandardError => e
        p e.message
      end
    end
  end

  def send_to_siat(invoice, reason)
    branch_office = invoice.branch_office
    daily_code = branch_office.daily_codes.where(point_of_sale: invoice.point_of_sale).current
    cuis_code = branch_office.cuis_codes.where(point_of_sale: invoice.point_of_sale).current

    client = SiatClient.client('siat_sales_invoice_service_wsdl', branch_office.company)

    body = {
      SolicitudServicioAnulacionFactura: {
        codigoAmbiente: branch_office.company.environment_type_id,
        codigoPuntoVenta: invoice.point_of_sale,
        codigoSistema: branch_office.company.company_setting.system_code,
        codigoSucursal: branch_office.number,
        nit: branch_office.company.nit.to_i,
        codigoDocumentoSector: branch_office.company.document_sector_types.first.code,
        codigoEmision: 1,
        codigoModalidad: branch_office.company.modality_id,
        cufd: daily_code.code,
        cuis: cuis_code.code,
        tipoFacturaDocumento: branch_office.company.invoice_types.first.code,
        codigoMotivo: reason,
        cuf: invoice.cuf
      }
    }
    begin
      response = client.call(:anulacion_factura, message: body)

      data = response.to_array(:anulacion_factura_response, :respuesta_servicio_facturacion).first

      if data[:transaccion]
        true
      else
        code = data[:mensajes_list][:codigo]
        description = data[:mensajes_list][:descripcion]
        invoice.invoice_logs.create(code: code, description: description)
        false
      end
    rescue StandardError => e
      invoice.invoice_logs.create(code: 900,
                                  description: "Se produjo un error al intentar anular la factura por el siguiente error: #{e}")
      false
    end
  end
end
